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

  Future<WeatherModel?> getCurrentWeather(String city) async {
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet) {
      try {
        // Try to fetch fresh data
        final weather = await _weatherService.getCurrentWeather(city);
        // Convert WeatherModel to CurrentWeather for caching
        final currentWeather = CurrentWeather(
          temperature: weather.temperature,
          condition: weather.description,
          description: weather.description,
          humidity: weather.humidity,
          pressure: 0,
          windSpeed: weather.windSpeed,
          windDirection: 0,
          visibility: weather.visibility.toDouble(),
          uvIndex: 0,
          feelsLike: weather.feelsLike,
        );
        await _databaseService.cacheCurrentWeather(city, currentWeather);
        return weather;
      } catch (e) {
        // If API fails, fall back to cache
        print('API failed, falling back to cache: $e');
      }
    }

    // Return cached data if no internet or API failed
    final cached = await _databaseService.getCachedCurrentWeather(city);
    if (cached == null) return null;
    // Convert CurrentWeather to WeatherModel with minimal fields (fallback)
    return WeatherModel(
      cityName: city,
      country: '',
      temperature: cached.temperature,
      feelsLike: cached.feelsLike,
      humidity: cached.humidity,
      windSpeed: cached.windSpeed,
      visibility: cached.visibility.toInt(),
      description: cached.description,
      icon: '',
      dateTime: DateTime.now(),
      hourlyForecast: [],
      dailyForecast: [],
    );
  }

  Future<List<DailyWeather>> getWeatherForecast(String city) async {
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet) {
      try {
        // Try to fetch fresh data
        final weather = await _weatherService.getCurrentWeather(city);
        final forecasts = weather.dailyForecast;
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
        final weather = await _weatherService.getCurrentWeather(city);
        final hourlyData = weather.hourlyForecast;
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
        WeatherModel model = current is WeatherModel
          ? current as WeatherModel
          : WeatherModel(
              cityName: city,
              country: '',
              temperature: current.temperature,
              feelsLike: current.feelsLike,
              humidity: current.humidity,
              windSpeed: current.windSpeed,
              visibility: current.visibility.toInt(),
              description: current.description,
              icon: '',
              dateTime: DateTime.now(),
              hourlyForecast: [],
              dailyForecast: [],
            );
        return WeatherData(
          current: model,
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
  final WeatherModel current;
  final List<DailyWeather> forecasts;
  final List<HourlyWeather> hourly;
  final bool isFromCache;

  WeatherData({
    required this.current,
    required this.forecasts,
    required this.hourly,
    required this.isFromCache,
  });
}
