import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../core/constants.dart';
import '../../core/app_routes.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/error_message.dart';
import 'widgets/rain_alert_banner.dart';
import 'widgets/weather_card.dart';
import 'widgets/hourly_forecast_card.dart';
import 'widgets/quick_actions_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().initialize();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<WeatherProvider>().refreshWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RideWeather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => AppRoutes.navigateToSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => AppRoutes.navigateToForecast(context),
          ),
        ],
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

          if (weatherProvider.currentWeather == null) {
            return const Center(
              child: Text('No weather data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Morning Rain Alert Banner
                  RainAlertBanner(weather: weatherProvider.currentWeather!),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  // Current Weather Card
                  WeatherCard(weather: weatherProvider.currentWeather!),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  // Morning Hours Forecast
                  if (weatherProvider.morningHoursForecast.isNotEmpty) ...[
                    HourlyForecastCard(
                      title: 'Morning Hours (5 AM - 9 AM)',
                      hourlyWeather: weatherProvider.morningHoursForecast,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                  ],
                  
                  // Today's Hourly Forecast
                  if (weatherProvider.currentWeather!.hourlyForecast.isNotEmpty) ...[
                    HourlyForecastCard(
                      title: 'Today\'s Forecast',
                      hourlyWeather: weatherProvider.currentWeather!.hourlyForecast,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                  ],
                  
                  // Quick Actions
                  QuickActionsCard(weatherProvider: weatherProvider),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
