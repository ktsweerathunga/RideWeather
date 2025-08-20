import 'package:flutter/material.dart';

class CustomWeatherIcons {
  static Widget getWeatherIcon(String condition, {double size = 48, Color? color}) {
    IconData iconData;
    Color iconColor = color ?? _getWeatherColor(condition);

    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        iconData = Icons.wb_sunny;
        break;
      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
        iconData = Icons.grain;
        break;
      case 'drizzle':
        iconData = Icons.grain;
        break;
      case 'thunderstorm':
        iconData = Icons.flash_on;
        break;
      case 'snow':
        iconData = Icons.ac_unit;
        break;
      case 'mist':
      case 'fog':
        iconData = Icons.blur_on;
        break;
      case 'clouds':
      case 'few clouds':
      case 'scattered clouds':
        iconData = Icons.wb_cloudy;
        break;
      case 'broken clouds':
      case 'overcast clouds':
        iconData = Icons.cloud;
        break;
      default:
        iconData = Icons.wb_sunny;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        size: size,
        color: iconColor,
      ),
    );
  }

  static Widget getAnimatedWeatherIcon(String condition, {double size = 48}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: getWeatherIcon(condition, size: size),
        );
      },
    );
  }

  static Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return const Color(0xFFEA580C); // Orange
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return const Color(0xFF1E40AF); // Blue
      case 'snow':
        return const Color(0xFF6B7280); // Gray
      case 'mist':
      case 'fog':
        return const Color(0xFF9CA3AF); // Light gray
      case 'clouds':
        return const Color(0xFF6B7280); // Gray
      default:
        return const Color(0xFF3B82F6); // Default blue
    }
  }

  static Widget getRainProbabilityIcon(int probability) {
    IconData iconData;
    Color iconColor;

    if (probability >= 80) {
      iconData = Icons.umbrella;
      iconColor = const Color(0xFFDC2626); // Red
    } else if (probability >= 60) {
      iconData = Icons.grain;
      iconColor = const Color(0xFFEA580C); // Orange
    } else if (probability >= 40) {
      iconData = Icons.cloud;
      iconColor = const Color(0xFFFBBF24); // Yellow
    } else if (probability >= 20) {
      iconData = Icons.wb_cloudy;
      iconColor = const Color(0xFF10B981); // Green
    } else {
      iconData = Icons.wb_sunny;
      iconColor = const Color(0xFF10B981); // Green
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            '$probability%',
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Widget getWindIcon(double windSpeed) {
    IconData iconData;
    Color iconColor;

    if (windSpeed >= 20) {
      iconData = Icons.air;
      iconColor = const Color(0xFFDC2626); // Red - Strong wind
    } else if (windSpeed >= 10) {
      iconData = Icons.air;
      iconColor = const Color(0xFFEA580C); // Orange - Moderate wind
    } else {
      iconData = Icons.air;
      iconColor = const Color(0xFF10B981); // Green - Light wind
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            '${windSpeed.toInt()} km/h',
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
