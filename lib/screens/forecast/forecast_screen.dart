import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/weather_provider.dart';
import '../../core/constants.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/error_message.dart';
import 'widgets/forecast_tile.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7-Day Forecast'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.status == WeatherStatus.loading) {
            return const Center(child: LoadingSpinner());
          }

          if (weatherProvider.status == WeatherStatus.error) {
            return Center(
              child: ErrorMessage(
                message: weatherProvider.errorMessage,
                onRetry: () => weatherProvider.refreshWeather(),
              ),
            );
          }

          final weather = weatherProvider.currentWeather;
          if (weather == null || weather.dailyForecast.isEmpty) {
            return const Center(
              child: Text('No forecast data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => weatherProvider.refreshWeather(),
            child: Column(
              children: [
                // Header with current location
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: AppConstants.primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            weatherProvider.isUsingCurrentLocation 
                                ? Icons.location_on 
                                : Icons.location_city,
                            color: AppConstants.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Text(
                            weather.cityName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppConstants.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Extended Weather Forecast',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Forecast List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: weather.dailyForecast.length,
                    itemBuilder: (context, index) {
                      final forecast = weather.dailyForecast[index];
                      final isToday = DateUtils.isSameDay(forecast.date, DateTime.now());
                      final isTomorrow = DateUtils.isSameDay(
                        forecast.date, 
                        DateTime.now().add(const Duration(days: 1)),
                      );
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                        child: ForecastTile(
                          forecast: forecast,
                          isToday: isToday,
                          isTomorrow: isTomorrow,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
