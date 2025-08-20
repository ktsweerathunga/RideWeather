import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String weatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // App Colors - Blue/White theme with Red/Green accents
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color backgroundWhite = Color(0xFFFAFAFA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color rainRed = Color(0xFFEF4444);
  static const Color clearGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  
  // Typography
  static const String fontFamily = 'DM Sans';
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeHuge = 32.0;
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  // Morning Hours for Rain Alert (5 AM - 9 AM)
  static const int morningStartHour = 5;
  static const int morningEndHour = 9;
  
  // Sri Lankan Cities
  static const List<String> sriLankanCities = [
    'Colombo',
    'Kandy',
    'Galle',
    'Jaffna',
    'Negombo',
    'Anuradhapura',
    'Trincomalee',
    'Batticaloa',
    'Matara',
    'Kurunegala',
  ];
}
