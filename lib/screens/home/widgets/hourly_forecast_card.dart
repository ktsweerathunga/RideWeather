import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/weather_model.dart';
import '../../../core/constants.dart';
import '../../../utils/weather_icon_mapper.dart';

class HourlyForecastCard extends StatelessWidget {
  final String title;
  final List<HourlyWeather> hourlyWeather;

  const HourlyForecastCard({
    super.key,
    required this.title,
    required this.hourlyWeather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyWeather.length,
                itemBuilder: (context, index) {
                  final hour = hourlyWeather[index];
                  return Container(
                    width: 80,
                    margin: EdgeInsets.only(
                      right: index < hourlyWeather.length - 1 
                          ? AppConstants.paddingMedium 
                          : 0,
                    ),
                    child: _HourlyWeatherItem(hourlyWeather: hour),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourlyWeatherItem extends StatelessWidget {
  final HourlyWeather hourlyWeather;

  const _HourlyWeatherItem({
    required this.hourlyWeather,
  });

  @override
  Widget build(BuildContext context) {
    final isNow = DateTime.now().difference(hourlyWeather.dateTime).abs().inHours < 1;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: isNow 
            ? AppConstants.primaryBlue.withOpacity(0.1)
            : AppConstants.backgroundWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: isNow 
            ? Border.all(color: AppConstants.primaryBlue, width: 2)
            : Border.all(color: AppConstants.textGray.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            isNow ? 'Now' : DateFormat('h a').format(hourlyWeather.dateTime),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
              color: isNow ? AppConstants.primaryBlue : AppConstants.textGray,
            ),
          ),
          Icon(
            WeatherIconMapper.getIconData(hourlyWeather.icon),
            size: 24,
            color: AppConstants.primaryBlue,
          ),
          Text(
            '${hourlyWeather.temperature.round()}°',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hourlyWeather.rainProbability > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 12,
                  color: AppConstants.primaryBlue,
                ),
                const SizedBox(width: 2),
                Text(
                  '${hourlyWeather.rainProbability.round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
