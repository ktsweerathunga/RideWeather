import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/weather_model.dart';
import 'weather_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const String _notificationEnabledKey = 'morning_rain_notifications_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _selectedCityKey = 'selected_city_for_notifications';

  // Initialize notifications
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    final DarwinFlutterLocalNotificationsPlugin? iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? false;
  }

  // Enable/disable notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
    
    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  static Future<void> setNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeKey, '$hour:$minute');
  }

  static Future<Map<String, int>> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_notificationTimeKey) ?? '6:0';
    final parts = timeString.split(':');
    return {
      'hour': int.parse(parts[0]),
      'minute': int.parse(parts[1]),
    };
  }

  static Future<void> setSelectedCityForNotifications(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCityKey, city);
  }

  static Future<String> getSelectedCityForNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedCityKey) ?? 'Colombo';
  }

  static Future<void> scheduleDailyMorningRainCheck() async {
    final bool enabled = await areNotificationsEnabled();
    if (!enabled) return;

    // Cancel existing scheduled notifications
    await _notifications.cancel(0);

    final timePrefs = await getNotificationTime();
    final selectedCity = await getSelectedCityForNotifications();

    // Schedule daily notification
    await _notifications.zonedSchedule(
      0,
      'Morning Weather Check',
      'Checking weather for your morning commute...',
      _nextInstanceOfTime(timePrefs['hour']!, timePrefs['minute']!),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_weather_check',
          'Daily Weather Check',
          channelDescription: 'Daily morning weather check for bike riders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF3B82F6),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> checkAndSendRainAlert() async {
    final bool enabled = await areNotificationsEnabled();
    if (!enabled) return;

    try {
      final selectedCity = await getSelectedCityForNotifications();
      final weatherService = WeatherService();
      final hourlyWeather = await weatherService.getHourlyWeather(selectedCity);
      
      if (hourlyWeather.isEmpty) return;

      // Check for rain in the next 4 hours (morning commute time)
      final now = DateTime.now();
      final morningHours = hourlyWeather.where((weather) {
        final hourDiff = weather.time.difference(now).inHours;
        return hourDiff >= 0 && hourDiff <= 4;
      }).toList();

      if (morningHours.isEmpty) return;

      final maxRainProbability = morningHours
          .map((w) => w.rainProbability)
          .reduce((a, b) => a > b ? a : b);

      if (maxRainProbability >= 60) {
        await _showMorningRainAlert(selectedCity, maxRainProbability, morningHours);
      } else if (maxRainProbability >= 30) {
        await _showMorningCloudyAlert(selectedCity, maxRainProbability);
      } else {
        await _showMorningClearAlert(selectedCity);
      }
    } catch (e) {
      print('Error checking rain alert: $e');
    }
  }

  static Future<void> _showMorningRainAlert(String city, int probability, List<HourlyWeather> morningHours) async {
    final rainTimes = morningHours
        .where((w) => w.rainProbability >= 60)
        .map((w) => '${w.time.hour}:${w.time.minute.toString().padLeft(2, '0')}')
        .join(', ');

    await _notifications.show(
      1,
      '🌧️ Rain Alert for $city!',
      'High chance of rain ($probability%) around $rainTimes. Consider alternative transport or carry rain gear!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_rain_alerts',
          'Morning Rain Alerts',
          channelDescription: 'Morning rain alerts for bike riders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFEF4444),
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> _showMorningCloudyAlert(String city, int probability) async {
    await _notifications.show(
      2,
      '☁️ Cloudy Morning in $city',
      'Possible light rain ($probability% chance). Keep an eye on the weather!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_weather_alerts',
          'Morning Weather Alerts',
          channelDescription: 'Morning weather updates for bike riders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFFBBF24),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> _showMorningClearAlert(String city) async {
    await _notifications.show(
      3,
      '☀️ Perfect Riding Weather!',
      'Clear skies in $city. Great day for your bike commute!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_weather_alerts',
          'Morning Weather Alerts',
          channelDescription: 'Morning weather updates for bike riders',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF10B981),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      ),
    );
  }

  // Show immediate rain alert
  static Future<void> showImmediateRainAlert(String city, String condition) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'immediate_rain_alerts',
      'Immediate Rain Alerts',
      channelDescription: 'Immediate rain alerts for current weather',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFEF4444),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String title = '⚠️ Rain Alert!';
    final String body = '$condition detected in $city. Take cover if you\'re riding!';

    await _notifications.show(4, title, body, details);
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> sendTestNotification() async {
    await _notifications.show(
      999,
      '🧪 Test Notification',
      'RideDry notifications are working correctly!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notifications',
          'Test Notifications',
          channelDescription: 'Test notifications for RideDry app',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF3B82F6),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
