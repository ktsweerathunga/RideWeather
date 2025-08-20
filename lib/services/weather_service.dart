import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = AppConstants.weatherBaseUrl;
  static const String _apiKey = AppConstants.weatherApiKey;

  // Get current weather by city name
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    try {
      final url = '$_baseUrl/weather?q=$cityName,LK&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = WeatherModel.fromJson(data);
        
        // Get hourly and daily forecasts
        final forecasts = await _getForecastData(cityName);
        return WeatherModel(
          cityName: weather.cityName,
          country: weather.country,
          temperature: weather.temperature,
          feelsLike: weather.feelsLike,
          humidity: weather.humidity,
          windSpeed: weather.windSpeed,
          visibility: weather.visibility,
          description: weather.description,
          icon: weather.icon,
          dateTime: weather.dateTime,
          hourlyForecast: forecasts['hourly'] ?? [],
          dailyForecast: forecasts['daily'] ?? [],
        );
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get weather by coordinates
  Future<WeatherModel> getCurrentWeatherByCoordinates(double lat, double lon) async {
    try {
      final url = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = WeatherModel.fromJson(data);
        
        // Get hourly and daily forecasts
        final forecasts = await _getForecastDataByCoordinates(lat, lon);
        return WeatherModel(
          cityName: weather.cityName,
          country: weather.country,
          temperature: weather.temperature,
          feelsLike: weather.feelsLike,
          humidity: weather.humidity,
          windSpeed: weather.windSpeed,
          visibility: weather.visibility,
          description: weather.description,
          icon: weather.icon,
          dateTime: weather.dateTime,
          hourlyForecast: forecasts['hourly'] ?? [],
          dailyForecast: forecasts['daily'] ?? [],
        );
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get forecast data by city name
  Future<Map<String, List<dynamic>>> _getForecastData(String cityName) async {
    try {
      final url = '$_baseUrl/forecast?q=$cityName,LK&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];

        // Parse hourly forecast (next 24 hours)
        final hourlyForecast = list
            .take(8) // Next 24 hours (3-hour intervals)
            .map((item) => HourlyWeather.fromJson(item))
            .toList();

        // Parse daily forecast (group by day)
        final dailyForecast = _groupForecastByDay(list);

        return {
          'hourly': hourlyForecast,
          'daily': dailyForecast,
        };
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  // Get forecast data by coordinates
  Future<Map<String, List<dynamic>>> _getForecastDataByCoordinates(double lat, double lon) async {
    try {
      final url = '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];

        // Parse hourly forecast (next 24 hours)
        final hourlyForecast = list
            .take(8) // Next 24 hours (3-hour intervals)
            .map((item) => HourlyWeather.fromJson(item))
            .toList();

        // Parse daily forecast (group by day)
        final dailyForecast = _groupForecastByDay(list);

        return {
          'hourly': hourlyForecast,
          'daily': dailyForecast,
        };
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  // Group forecast data by day for daily forecast
  List<DailyWeather> _groupForecastByDay(List<dynamic> forecastList) {
    final Map<String, List<dynamic>> groupedByDay = {};
    
    for (final item in forecastList) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey = '${date.year}-${date.month}-${date.day}';
      
      if (!groupedByDay.containsKey(dayKey)) {
        groupedByDay[dayKey] = [];
      }
      groupedByDay[dayKey]!.add(item);
    }

    final List<DailyWeather> dailyWeather = [];
    
    groupedByDay.forEach((day, items) {
      if (items.isNotEmpty) {
        // Get the item closest to noon for representative weather
        final noonItem = items.reduce((a, b) {
          final aTime = DateTime.fromMillisecondsSinceEpoch(a['dt'] * 1000);
          final bTime = DateTime.fromMillisecondsSinceEpoch(b['dt'] * 1000);
          final aNoonDiff = (aTime.hour - 12).abs();
          final bNoonDiff = (bTime.hour - 12).abs();
          return aNoonDiff < bNoonDiff ? a : b;
        });

        // Calculate min/max temperatures for the day
        final temps = items.map((item) => (item['main']['temp'] as num).toDouble()).toList();
        final maxTemp = temps.reduce((a, b) => a > b ? a : b);
        final minTemp = temps.reduce((a, b) => a < b ? a : b);

        // Calculate average rain probability
        final rainProbs = items.map((item) => ((item['pop'] ?? 0) as num).toDouble()).toList();
        final avgRainProb = rainProbs.reduce((a, b) => a + b) / rainProbs.length * 100;

        dailyWeather.add(DailyWeather(
          date: DateTime.fromMillisecondsSinceEpoch(noonItem['dt'] * 1000),
          maxTemp: maxTemp,
          minTemp: minTemp,
          rainProbability: avgRainProb,
          description: noonItem['weather'][0]['description'],
          icon: noonItem['weather'][0]['icon'],
          windSpeed: (noonItem['wind']['speed'] as num).toDouble(),
          humidity: noonItem['main']['humidity'],
        ));
      }
    });

    return dailyWeather.take(7).toList(); // Return 7-day forecast
  }
}
