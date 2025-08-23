class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final String description;
  final String icon;
  final DateTime dateTime;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.description,
    required this.icon,
    required this.dateTime,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      visibility: json['visibility'] ?? 0,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      hourlyForecast: [],
      dailyForecast: [],
    );
  }

  // Check if there's rain in morning hours (5 AM - 9 AM)
  bool get hasMorningRain {
    final morningHours = hourlyForecast.where((hour) {
      final hourOfDay = hour.dateTime.hour;
      return hourOfDay >= 5 && hourOfDay <= 9;
    });
    
    return morningHours.any((hour) => hour.rainProbability > 30);
  }

  // Get morning rain probability percentage
  double get morningRainProbability {
    final morningHours = hourlyForecast.where((hour) {
      final hourOfDay = hour.dateTime.hour;
      return hourOfDay >= 5 && hourOfDay <= 9;
    });
    
    if (morningHours.isEmpty) return 0;
    
    return morningHours.map((h) => h.rainProbability).reduce((a, b) => a + b) / morningHours.length;
  }
}

class HourlyWeather {
  final DateTime dateTime;
  final double temperature;
  final double rainProbability;
  final String description;
  final String icon;
  final double windSpeed;

  HourlyWeather({
    required this.dateTime,
    required this.temperature,
    required this.rainProbability,
    required this.description,
    required this.icon,
    required this.windSpeed,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      rainProbability: ((json['pop'] ?? 0) as num).toDouble() * 100,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}

class DailyWeather {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double rainProbability;
  final String description;
  final String icon;
  final double windSpeed;
  final int humidity;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainProbability,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.humidity,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['temp']['max'] as num).toDouble(),
      minTemp: (json['temp']['min'] as num).toDouble(),
      rainProbability: ((json['pop'] ?? 0) as num).toDouble() * 100,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      windSpeed: (json['wind_speed'] as num).toDouble(),
      humidity: json['humidity'] ?? 0,
    );
  }
}

// Add your weather models here, e.g. WeatherForecast, HourlyWeather, etc.

class CurrentWeather {
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDirection;
  final double visibility;
  final double uvIndex;
  final double feelsLike;

  CurrentWeather({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.uvIndex,
    required this.feelsLike,
  });
}