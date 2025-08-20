import 'dart:io';
import '../models/weather_model.dart';
import 'weather_service.dart';
import 'database_service.dart';

class OfflineWeatherService {
  final WeatherService _weatherService = WeatherService();
  final DatabaseService _databaseService = DatabaseService();

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<CurrentWeather?> getCurrentWeather(String city) async {
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet) {
      try {
        // Try to fetch fresh data
        final weather = await _weatherService.getCurrentWeather(city);
        if (weather != null) {
          // Cache the fresh data
          await _databaseService.cacheCurrentWeather(city, weather);
          return weather;
        }
      } catch (e) {
        // If API fails, fall back to cache
        print('API failed, falling back to cache: $e');
      }
    }

    // Return cached data if no internet or API failed
    return await _databaseService.getCachedCurrentWeather(city);
  }

  Future<List<WeatherForecast>> getWeatherForecast(String city) async {
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet) {
      try {
        // Try to fetch fresh data
        final forecasts = await _weatherService.getWeatherForecast(city);
        if (forecasts.isNotEmpty) {
          // Cache the fresh data
          await _databaseService.cacheForecast(city, forecasts);
          return forecasts;
        }
      } catch (e) {
        // If API fails, fall back to cache
        print('API failed, falling back to cache: $e');
      }
    }

    // Return cached data if no internet or API failed
    return await _databaseService.getCachedForecast(city);
  }

  Future<List<HourlyWeather>> getHourlyWeather(String city) async {
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet) {
      try {
        // Try to fetch fresh data
        final hourlyData = await _weatherService.getHourlyWeather(city);
        if (hourlyData.isNotEmpty) {
          // Cache the fresh data
          await _databaseService.cacheHourlyWeather(city, hourlyData);
          return hourlyData;
        }
      } catch (e) {
        // If API fails, fall back to cache
        print('API failed, falling back to cache: $e');
      }
    }

    // Return cached data if no internet or API failed
    return await _databaseService.getCachedHourlyWeather(city);
  }

  Future<WeatherData?> getCompleteWeatherData(String city) async {
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet && await _databaseService.isCacheValid(city)) {
      // If we have internet and cache is still valid, use cache for better performance
      final current = await _databaseService.getCachedCurrentWeather(city);
      final forecasts = await _databaseService.getCachedForecast(city);
      final hourly = await _databaseService.getCachedHourlyWeather(city);
      
      if (current != null) {
        return WeatherData(
          current: current,
          forecasts: forecasts,
          hourly: hourly,
          isFromCache: true,
        );
      }
    }

    // Fetch fresh data
    final current = await getCurrentWeather(city);
    final forecasts = await getWeatherForecast(city);
    final hourly = await getHourlyWeather(city);

    if (current != null) {
      return WeatherData(
        current: current,
        forecasts: forecasts,
        hourly: hourly,
        isFromCache: !hasInternet,
      );
    }

    return null;
  }

  // Favorite locations management
  Future<void> addFavoriteLocation(String city) async {
    await _databaseService.addFavoriteLocation(city);
  }

  Future<void> removeFavoriteLocation(String city) async {
    await _databaseService.removeFavoriteLocation(city);
  }

  Future<List<String>> getFavoriteLocations() async {
    return await _databaseService.getFavoriteLocations();
  }

  Future<bool> isFavoriteLocation(String city) async {
    return await _databaseService.isFavoriteLocation(city);
  }

  // Cache management
  Future<void> clearOldCache() async {
    await _databaseService.clearOldCache();
  }

  Future<void> clearAllCache() async {
    await _databaseService.clearAllCache();
  }

  Future<bool> hasInternetConnection() async {
    return await _hasInternetConnection();
  }
}

class WeatherData {
  final CurrentWeather current;
  final List<WeatherForecast> forecasts;
  final List<HourlyWeather> hourly;
  final bool isFromCache;

  WeatherData({
    required this.current,
    required this.forecasts,
    required this.hourly,
    required this.isFromCache,
  });
}
