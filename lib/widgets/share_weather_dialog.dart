import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/weather_model.dart';

class ShareWeatherDialog extends StatelessWidget {
  final String city;
  final CurrentWeather weather;

  const ShareWeatherDialog({
    super.key,
    required this.city,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(Icons.share, color: Color(0xFF3B82F6)),
          SizedBox(width: 10),
          Text('Share Weather'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share the current weather in $city with your friends:',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${weather.temperature.toInt()}°C • ${weather.condition}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Humidity: ${weather.humidity}% • Wind: ${weather.windSpeed.toInt()} km/h',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _shareWeather();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ],
    );
  }

  void _shareWeather() {
    final message = '''
🌤️ Weather Update for $city

🌡️ Temperature: ${weather.temperature.toInt()}°C
☁️ Condition: ${weather.condition}
💧 Humidity: ${weather.humidity}%
💨 Wind: ${weather.windSpeed.toInt()} km/h
👁️ Visibility: ${weather.visibility} km

Perfect for planning your bike ride! 🚴‍♂️

Shared via RideDry - Sri Lanka Weather App
    ''';

    Share.share(message);
  }
}
