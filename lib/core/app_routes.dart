import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/forecast/forecast_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/settings/notification_settings_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String forecast = '/forecast';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String notificationSettings = '/notification-settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      forecast: (context) => const ForecastScreen(),
      search: (context) => const SearchScreen(),
      favorites: (context) => const FavoritesScreen(),
      notificationSettings: (context) => const NotificationSettingsScreen(),
    };
  }

  static void navigateToForecast(BuildContext context) {
    Navigator.pushNamed(context, forecast);
  }

  static void navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, search);
  }

  static void navigateToFavorites(BuildContext context) {
    Navigator.pushNamed(context, favorites);
  }

  static void navigateToNotificationSettings(BuildContext context) {
    Navigator.pushNamed(context, notificationSettings);
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
}
