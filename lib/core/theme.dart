import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppConstants.fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryBlue,
        brightness: Brightness.light,
        surface: AppConstants.backgroundWhite,
        onSurface: AppConstants.textDark,
      ),
      scaffoldBackgroundColor: AppConstants.backgroundWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.cardWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: AppConstants.fontSizeHuge,
          fontWeight: FontWeight.bold,
          color: AppConstants.textDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: AppConstants.fontSizeXXLarge,
          fontWeight: FontWeight.w600,
          color: AppConstants.textDark,
        ),
        titleLarge: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: AppConstants.textDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: AppConstants.fontSizeLarge,
          color: AppConstants.textDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: AppConstants.fontSizeMedium,
          color: AppConstants.textGray,
        ),
        bodySmall: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: AppConstants.fontSizeSmall,
          color: AppConstants.textGray,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppConstants.fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1F2937),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }
}
