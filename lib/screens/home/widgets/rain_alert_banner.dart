import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/weather_model.dart';
import '../../../providers/weather_provider.dart';
import '../../../core/constants.dart';

class RainAlertBanner extends StatelessWidget {
  final WeatherModel weather;

  const RainAlertBanner({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final status = weatherProvider.morningRainStatus;
        final message = weatherProvider.morningRainMessage;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color: status.color.withOpacity(0.1),
            border: Border.all(color: status.color, width: 2),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingSmall),
                    decoration: BoxDecoration(
                      color: status.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Morning Ride Alert',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: status.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: status.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(color: status.color.withOpacity(0.2)),
                ),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppConstants.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
