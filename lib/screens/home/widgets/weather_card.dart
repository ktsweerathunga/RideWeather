import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/weather_model.dart';
import '../../../core/constants.dart';
import '../../../utils/weather_icon_mapper.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            // Location and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.cityName,
                        style: Theme.of(context).textTheme.headlineMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat('EEEE, MMM d • h:mm a').format(weather.dateTime),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  WeatherIconMapper.getIconData(weather.icon),
                  size: 48,
                  color: AppConstants.primaryBlue,
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Temperature and Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.round()}°',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        weather.description.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Feels like ${weather.feelsLike.round()}°',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Weather Details Grid
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.backgroundWhite,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _WeatherDetailItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${weather.humidity}%',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppConstants.textGray.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _WeatherDetailItem(
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppConstants.textGray.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _WeatherDetailItem(
                      icon: Icons.visibility,
                      label: 'Visibility',
                      value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppConstants.primaryBlue,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
