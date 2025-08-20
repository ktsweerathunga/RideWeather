import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'custom_weather_icons.dart';

class WeatherMetricsCard extends StatelessWidget {
  final CurrentWeather weather;

  const WeatherMetricsCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.visibility,
                    label: 'Visibility',
                    value: '${weather.visibility} km',
                    color: const Color(0xFF10B981),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${weather.humidity}%',
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.compress,
                    label: 'Pressure',
                    value: '${weather.pressure} hPa',
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.thermostat,
                    label: 'Feels Like',
                    value: '${weather.feelsLike.toInt()}°C',
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomWeatherIcons.getWindIcon(weather.windSpeed),
                ),
                Expanded(
                  child: _buildUVIndex(weather.uvIndex),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUVIndex(double uvIndex) {
    Color uvColor;
    String uvLevel;

    if (uvIndex <= 2) {
      uvColor = const Color(0xFF10B981); // Green - Low
      uvLevel = 'Low';
    } else if (uvIndex <= 5) {
      uvColor = const Color(0xFFFBBF24); // Yellow - Moderate
      uvLevel = 'Moderate';
    } else if (uvIndex <= 7) {
      uvColor = const Color(0xFFEA580C); // Orange - High
      uvLevel = 'High';
    } else if (uvIndex <= 10) {
      uvColor = const Color(0xFFDC2626); // Red - Very High
      uvLevel = 'Very High';
    } else {
      uvColor = const Color(0xFF7C2D12); // Dark Red - Extreme
      uvLevel = 'Extreme';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: uvColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.wb_sunny, color: uvColor, size: 24),
          const SizedBox(height: 4),
          Text(
            uvIndex.toInt().toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: uvColor,
              fontSize: 14,
            ),
          ),
          Text(
            'UV $uvLevel',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
