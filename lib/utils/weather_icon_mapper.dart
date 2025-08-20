import 'package:flutter/material.dart';

class WeatherIconMapper {
  // Map OpenWeatherMap icon codes to Flutter Material Icons
  static IconData getIconData(String iconCode) {
    switch (iconCode) {
      // Clear sky
      case '01d': // clear sky day
        return Icons.wb_sunny;
      case '01n': // clear sky night
        return Icons.nights_stay;
      
      // Few clouds
      case '02d': // few clouds day
        return Icons.wb_cloudy;
      case '02n': // few clouds night
        return Icons.cloud;
      
      // Scattered clouds
      case '03d':
      case '03n':
        return Icons.cloud;
      
      // Broken clouds
      case '04d':
      case '04n':
        return Icons.cloud_queue;
      
      // Shower rain
      case '09d':
      case '09n':
        return Icons.grain;
      
      // Rain
      case '10d': // rain day
        return Icons.umbrella;
      case '10n': // rain night
        return Icons.umbrella;
      
      // Thunderstorm
      case '11d':
      case '11n':
        return Icons.thunderstorm;
      
      // Snow
      case '13d':
      case '13n':
        return Icons.ac_unit;
      
      // Mist/Fog
      case '50d':
      case '50n':
        return Icons.foggy;
      
      // Default fallback
      default:
        return Icons.wb_cloudy;
    }
  }

  // Get weather condition color
  static Color getWeatherColor(String iconCode) {
    switch (iconCode) {
      // Clear/Sunny
      case '01d':
        return Colors.orange;
      case '01n':
        return Colors.indigo;
      
      // Cloudy
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Colors.grey;
      
      // Rain
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Colors.blue;
      
      // Thunderstorm
      case '11d':
      case '11n':
        return Colors.deepPurple;
      
      // Snow
      case '13d':
      case '13n':
        return Colors.lightBlue;
      
      // Mist/Fog
      case '50d':
      case '50n':
        return Colors.blueGrey;
      
      default:
        return Colors.grey;
    }
  }

  // Get weather description
  static String getWeatherDescription(String iconCode) {
    switch (iconCode) {
      case '01d':
        return 'Clear Sky';
      case '01n':
        return 'Clear Night';
      case '02d':
        return 'Few Clouds';
      case '02n':
        return 'Partly Cloudy';
      case '03d':
      case '03n':
        return 'Scattered Clouds';
      case '04d':
      case '04n':
        return 'Broken Clouds';
      case '09d':
      case '09n':
        return 'Shower Rain';
      case '10d':
        return 'Rain';
      case '10n':
        return 'Night Rain';
      case '11d':
      case '11n':
        return 'Thunderstorm';
      case '13d':
      case '13n':
        return 'Snow';
      case '50d':
      case '50n':
        return 'Mist';
      default:
        return 'Unknown';
    }
  }

  // Check if weather condition indicates rain
  static bool isRainy(String iconCode) {
    return ['09d', '09n', '10d', '10n', '11d', '11n'].contains(iconCode);
  }

  // Check if weather condition is clear
  static bool isClear(String iconCode) {
    return ['01d', '01n'].contains(iconCode);
  }

  // Check if weather condition is cloudy
  static bool isCloudy(String iconCode) {
    return ['02d', '02n', '03d', '03n', '04d', '04n'].contains(iconCode);
  }

  // Get rain intensity level (0-3)
  static int getRainIntensity(String iconCode) {
    switch (iconCode) {
      case '09d':
      case '09n':
        return 2; // Moderate rain
      case '10d':
      case '10n':
        return 1; // Light rain
      case '11d':
      case '11n':
        return 3; // Heavy rain (thunderstorm)
      default:
        return 0; // No rain
    }
  }
}
