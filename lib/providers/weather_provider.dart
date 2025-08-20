import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../core/constants.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  // State variables
  WeatherModel? _currentWeather;
  WeatherStatus _status = WeatherStatus.initial;
  String _errorMessage = '';
  String _selectedCity = 'Colombo';
  bool _isUsingCurrentLocation = false;
  bool _notificationsEnabled = false;
  DateTime? _lastUpdated;

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  WeatherStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get selectedCity => _selectedCity;
  bool get isUsingCurrentLocation => _isUsingCurrentLocation;
  bool get notificationsEnabled => _notificationsEnabled;
  DateTime? get lastUpdated => _lastUpdated;

  // Check if data needs refresh (older than 30 minutes)
  bool get needsRefresh {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > 30;
  }

  // Initialize provider
  Future<void> initialize() async {
    await _loadPreferences();
    await _loadNotificationSettings();
    
    if (_isUsingCurrentLocation) {
      await fetchWeatherByLocation();
    } else {
      await fetchWeatherByCity(_selectedCity);
    }
  }

  // Load saved preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedCity = prefs.getString('selected_city') ?? 'Colombo';
      _isUsingCurrentLocation = prefs.getBool('use_current_location') ?? false;
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Save preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_city', _selectedCity);
      await prefs.setBool('use_current_location', _isUsingCurrentLocation);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  // Load notification settings
  Future<void> _loadNotificationSettings() async {
    _notificationsEnabled = await NotificationService.areNotificationsEnabled();
    notifyListeners();
  }

  // Fetch weather by city name
  Future<void> fetchWeatherByCity(String cityName) async {
    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final weather = await _weatherService.getCurrentWeather(cityName);
      _currentWeather = weather;
      _selectedCity = cityName;
      _isUsingCurrentLocation = false;
      _status = WeatherStatus.loaded;
      _lastUpdated = DateTime.now();
      
      await _savePreferences();
      
      // Schedule morning rain alert if notifications are enabled
      if (_notificationsEnabled) {
        await NotificationService.scheduleMorningRainAlert(weather);
      }
      
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    
    notifyListeners();
  }

  // Fetch weather by current location
  Future<void> fetchWeatherByLocation() async {
    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      final weather = await _weatherService.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      
      _currentWeather = weather;
      _selectedCity = weather.cityName;
      _isUsingCurrentLocation = true;
      _status = WeatherStatus.loaded;
      _lastUpdated = DateTime.now();
      
      await _savePreferences();
      
      // Schedule morning rain alert if notifications are enabled
      if (_notificationsEnabled) {
        await NotificationService.scheduleMorningRainAlert(weather);
      }
      
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Fallback to default city if location fails
      if (_selectedCity.isNotEmpty) {
        await fetchWeatherByCity(_selectedCity);
        return;
      }
    }
    
    notifyListeners();
  }

  // Refresh current weather data
  Future<void> refreshWeather() async {
    if (_isUsingCurrentLocation) {
      await fetchWeatherByLocation();
    } else {
      await fetchWeatherByCity(_selectedCity);
    }
  }

  // Toggle between current location and selected city
  Future<void> toggleLocationMode() async {
    if (_isUsingCurrentLocation) {
      // Switch to city mode
      await fetchWeatherByCity(_selectedCity);
    } else {
      // Switch to location mode
      await fetchWeatherByLocation();
    }
  }

  // Set selected city
  Future<void> setSelectedCity(String cityName) async {
    if (cityName != _selectedCity) {
      await fetchWeatherByCity(cityName);
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    try {
      if (!_notificationsEnabled) {
        // Request permission first
        final granted = await NotificationService.requestPermissions();
        if (!granted) {
          _errorMessage = 'Notification permission denied';
          notifyListeners();
          return;
        }
      }

      _notificationsEnabled = !_notificationsEnabled;
      await NotificationService.setNotificationsEnabled(_notificationsEnabled);
      
      if (_notificationsEnabled && _currentWeather != null) {
        // Schedule morning rain alert
        await NotificationService.scheduleMorningRainAlert(_currentWeather!);
      } else {
        // Cancel all notifications
        await NotificationService.cancelAllNotifications();
      }
      
    } catch (e) {
      _errorMessage = 'Error updating notification settings: $e';
    }
    
    notifyListeners();
  }

  // Get morning rain status for UI
  MorningRainStatus get morningRainStatus {
    if (_currentWeather == null) return MorningRainStatus.unknown;
    
    final rainProbability = _currentWeather!.morningRainProbability;
    
    if (rainProbability >= 70) return MorningRainStatus.highRain;
    if (rainProbability >= 40) return MorningRainStatus.moderateRain;
    if (rainProbability >= 20) return MorningRainStatus.lightRain;
    return MorningRainStatus.noRain;
  }

  // Get morning rain alert message
  String get morningRainMessage {
    if (_currentWeather == null) return 'Weather data unavailable';
    
    final status = morningRainStatus;
    final probability = _currentWeather!.morningRainProbability.toInt();
    
    switch (status) {
      case MorningRainStatus.highRain:
        return 'Heavy rain expected (${probability}% chance). Consider alternative transport.';
      case MorningRainStatus.moderateRain:
        return 'Moderate rain likely (${probability}% chance). Carry rain gear.';
      case MorningRainStatus.lightRain:
        return 'Light rain possible (${probability}% chance). Stay alert.';
      case MorningRainStatus.noRain:
        return 'Clear morning ahead (${probability}% rain chance). Safe to ride!';
      case MorningRainStatus.unknown:
        return 'Weather data unavailable';
    }
  }

  // Get morning hours forecast (5 AM - 9 AM)
  List<HourlyWeather> get morningHoursForecast {
    if (_currentWeather == null) return [];
    
    return _currentWeather!.hourlyForecast.where((hour) {
      final hourOfDay = hour.dateTime.hour;
      return hourOfDay >= AppConstants.morningStartHour && 
             hourOfDay <= AppConstants.morningEndHour;
    }).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Check if location permission is available
  Future<bool> checkLocationPermission() async {
    try {
      final permission = await _locationService.checkLocationPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }
}

// Enum for morning rain status
enum MorningRainStatus {
  noRain,
  lightRain,
  moderateRain,
  highRain,
  unknown,
}

// Extension for morning rain status colors
extension MorningRainStatusExtension on MorningRainStatus {
  Color get color {
    switch (this) {
      case MorningRainStatus.noRain:
        return AppConstants.clearGreen;
      case MorningRainStatus.lightRain:
        return AppConstants.warningAmber;
      case MorningRainStatus.moderateRain:
        return AppConstants.rainRed;
      case MorningRainStatus.highRain:
        return AppConstants.rainRed;
      case MorningRainStatus.unknown:
        return AppConstants.textGray;
    }
  }

  IconData get icon {
    switch (this) {
      case MorningRainStatus.noRain:
        return Icons.wb_sunny;
      case MorningRainStatus.lightRain:
        return Icons.cloud;
      case MorningRainStatus.moderateRain:
        return Icons.grain;
      case MorningRainStatus.highRain:
        return Icons.thunderstorm;
      case MorningRainStatus.unknown:
        return Icons.help_outline;
    }
  }

  String get label {
    switch (this) {
      case MorningRainStatus.noRain:
        return 'Clear';
      case MorningRainStatus.lightRain:
        return 'Light Rain';
      case MorningRainStatus.moderateRain:
        return 'Moderate Rain';
      case MorningRainStatus.highRain:
        return 'Heavy Rain';
      case MorningRainStatus.unknown:
        return 'Unknown';
    }
  }
}
