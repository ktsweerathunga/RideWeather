import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/weather_model.dart';
import '../../../core/constants.dart';
import '../../../utils/weather_icon_mapper.dart';

class ForecastTile extends StatelessWidget {
  final DailyWeather forecast;
  final bool isToday;
  final bool isTomorrow;

  const ForecastTile({
    super.key,
    required this.forecast,
    this.isToday = false,
    this.isTomorrow = false,
  });

  @override
  Widget build(BuildContext context) {
    String dayLabel;
    if (isToday) {
      dayLabel = 'Today';
    } else if (isTomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = DateFormat('EEEE').format(forecast.date);
    }

    final rainColor = _getRainColor(forecast.rainProbability);

    return Card(
      elevation: isToday ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: isToday 
              ? Border.all(color: AppConstants.primaryBlue, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            children: [
              // Main forecast row
              Row(
                children: [
                  // Day and Date
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayLabel,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                            color: isToday ? AppConstants.primaryBlue : AppConstants.textDark,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d').format(forecast.date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  // Weather Icon
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Icon(
                      WeatherIconMapper.getIconData(forecast.icon),
                      size: 32,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                  
                  const SizedBox(width: AppConstants.paddingMedium),
                  
                  // Temperature Range
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${forecast.maxTemp.round()}°',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textDark,
                        ),
                      ),
                      Text(
                        '${forecast.minTemp.round()}°',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppConstants.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Weather Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundWhite,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  forecast.description.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Weather Details
              Row(
                children: [
                  // Rain Probability
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.water_drop,
                      label: 'Rain',
                      value: '${forecast.rainProbability.round()}%',
                      valueColor: rainColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppConstants.textGray.withOpacity(0.3),
                  ),
                  // Humidity
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.opacity,
                      label: 'Humidity',
                      value: '${forecast.humidity}%',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppConstants.textGray.withOpacity(0.3),
                  ),
                  // Wind Speed
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${forecast.windSpeed.toStringAsFixed(1)} m/s',
                    ),
                  ),
                ],
              ),
              
              // Morning Rain Alert for Tomorrow
              if (isTomorrow && forecast.rainProbability > 30) ...[
                const SizedBox(height: AppConstants.paddingMedium),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppConstants.rainRed.withOpacity(0.1),
                    border: Border.all(color: AppConstants.rainRed.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppConstants.rainRed,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Expanded(
                        child: Text(
                          'Morning rain likely tomorrow. Plan your ride accordingly!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppConstants.rainRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRainColor(double rainProbability) {
    if (rainProbability >= 70) return AppConstants.rainRed;
    if (rainProbability >= 40) return AppConstants.warningAmber;
    if (rainProbability >= 20) return AppConstants.primaryBlue;
    return AppConstants.clearGreen;
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppConstants.primaryBlue,
          size: 18,
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppConstants.textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
