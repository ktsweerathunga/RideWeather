import 'package:flutter/material.dart';
import '../core/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _weatherCondition = 'clear';

  ThemeMode get themeMode => _themeMode;
  String get weatherCondition => _weatherCondition;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void updateWeatherTheme(String condition) {
    _weatherCondition = condition.toLowerCase();
    notifyListeners();
  }

  ThemeData getDynamicTheme(Brightness brightness) {
    Color primaryColor;
    Color backgroundColor;
    Color cardColor;
    
    switch (_weatherCondition) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        primaryColor = const Color(0xFF1E40AF); // Deep blue
        backgroundColor = brightness == Brightness.light 
            ? const Color(0xFFE0F2FE) 
            : const Color(0xFF0F172A);
        cardColor = brightness == Brightness.light 
            ? const Color(0xFFBAE6FD) 
            : const Color(0xFF1E293B);
        break;
      case 'clear':
      case 'sunny':
        primaryColor = const Color(0xFFEA580C); // Orange
        backgroundColor = brightness == Brightness.light 
            ? const Color(0xFFFFF7ED) 
            : const Color(0xFF1C1917);
        cardColor = brightness == Brightness.light 
            ? const Color(0xFFFED7AA) 
            : const Color(0xFF292524);
        break;
      case 'clouds':
      case 'overcast':
        primaryColor = const Color(0xFF6B7280); // Gray
        backgroundColor = brightness == Brightness.light 
            ? const Color(0xFFF9FAFB) 
            : const Color(0xFF111827);
        cardColor = brightness == Brightness.light 
            ? const Color(0xFFE5E7EB) 
            : const Color(0xFF1F2937);
        break;
      default:
        primaryColor = const Color(0xFF3B82F6); // Default blue
        backgroundColor = brightness == Brightness.light 
            ? Colors.white 
            : const Color(0xFF111827);
        cardColor = brightness == Brightness.light 
            ? const Color(0xFFF8FAFC) 
            : const Color(0xFF1F2937);
    }

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'DM Sans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
