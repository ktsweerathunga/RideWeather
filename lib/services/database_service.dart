import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/weather_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'weather_cache.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _currentWeatherTable = 'current_weather';
  static const String _forecastTable = 'weather_forecast';
  static const String _hourlyWeatherTable = 'hourly_weather';
  static const String _favoritesTable = 'favorite_locations';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Current weather table
    await db.execute('''
      CREATE TABLE $_currentWeatherTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT NOT NULL,
        temperature REAL NOT NULL,
        condition TEXT NOT NULL,
        description TEXT NOT NULL,
        humidity INTEGER NOT NULL,
        pressure INTEGER NOT NULL,
        windSpeed REAL NOT NULL,
        windDirection INTEGER NOT NULL,
        visibility REAL NOT NULL,
        uvIndex REAL NOT NULL,
        feelsLike REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        UNIQUE(city)
      )
    ''');

    // Weather forecast table
    await db.execute('''
      CREATE TABLE $_forecastTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT NOT NULL,
        date INTEGER NOT NULL,
        maxTemp REAL NOT NULL,
        minTemp REAL NOT NULL,
        condition TEXT NOT NULL,
        description TEXT NOT NULL,
        humidity INTEGER NOT NULL,
        windSpeed REAL NOT NULL,
        rainProbability INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        UNIQUE(city, date)
      )
    ''');

    // Hourly weather table
    await db.execute('''
      CREATE TABLE $_hourlyWeatherTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT NOT NULL,
        time INTEGER NOT NULL,
        temperature REAL NOT NULL,
        condition TEXT NOT NULL,
        rainProbability INTEGER NOT NULL,
        windSpeed REAL NOT NULL,
        humidity INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        UNIQUE(city, time)
      )
    ''');

    // Favorite locations table
    await db.execute('''
      CREATE TABLE $_favoritesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT NOT NULL UNIQUE,
        latitude REAL,
        longitude REAL,
        addedAt INTEGER NOT NULL
      )
    ''');
  }

  // Current Weather Operations
  Future<void> cacheCurrentWeather(String city, CurrentWeather weather) async {
    final db = await database;
    await db.insert(
      _currentWeatherTable,
      {
        'city': city,
        'temperature': weather.temperature,
        'condition': weather.condition,
        'description': weather.description,
        'humidity': weather.humidity,
        'pressure': weather.pressure,
        'windSpeed': weather.windSpeed,
        'windDirection': weather.windDirection,
        'visibility': weather.visibility,
        'uvIndex': weather.uvIndex,
        'feelsLike': weather.feelsLike,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CurrentWeather?> getCachedCurrentWeather(String city) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _currentWeatherTable,
      where: 'city = ?',
      whereArgs: [city],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return CurrentWeather(
        temperature: map['temperature'],
        condition: map['condition'],
        description: map['description'],
        humidity: map['humidity'],
        pressure: map['pressure'],
        windSpeed: map['windSpeed'],
        windDirection: map['windDirection'],
        visibility: map['visibility'],
        uvIndex: map['uvIndex'],
        feelsLike: map['feelsLike'],
      );
    }
    return null;
  }

  // Forecast Operations
  Future<void> cacheForecast(String city, List<DailyWeather> forecasts) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing forecasts for this city
    batch.delete(_forecastTable, where: 'city = ?', whereArgs: [city]);

    // Insert new forecasts
    for (final forecast in forecasts) {
      batch.insert(_forecastTable, {
        'city': city,
        'date': forecast.date.millisecondsSinceEpoch,
        'maxTemp': forecast.maxTemp,
        'minTemp': forecast.minTemp,
        'condition': forecast.description,
        'description': forecast.description,
        'humidity': forecast.humidity,
        'windSpeed': forecast.windSpeed,
        'rainProbability': forecast.rainProbability,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    await batch.commit();
  }

  Future<List<DailyWeather>> getCachedForecast(String city) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _forecastTable,
      where: 'city = ?',
      whereArgs: [city],
      orderBy: 'date ASC',
    );

    return maps.map((map) => DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      maxTemp: map['maxTemp'],
      minTemp: map['minTemp'],
      rainProbability: map['rainProbability'].toDouble(),
      description: map['description'],
      icon: '',
      windSpeed: map['windSpeed'],
      humidity: map['humidity'],
    )).toList();
  }

  // Hourly Weather Operations
  Future<void> cacheHourlyWeather(String city, List<HourlyWeather> hourlyData) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing hourly data for this city (keep only last 24 hours)
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
    batch.delete(
      _hourlyWeatherTable,
      where: 'city = ? AND time < ?',
      whereArgs: [city, cutoffTime.millisecondsSinceEpoch],
    );

    // Insert new hourly data
    for (final hourly in hourlyData) {
      batch.insert(
        _hourlyWeatherTable,
        {
          'city': city,
          'time': hourly.dateTime.millisecondsSinceEpoch,
          'temperature': hourly.temperature,
          'condition': hourly.description,
          'rainProbability': hourly.rainProbability,
          'windSpeed': hourly.windSpeed,
          'humidity': 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<HourlyWeather>> getCachedHourlyWeather(String city) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _hourlyWeatherTable,
      where: 'city = ?',
      whereArgs: [city],
      orderBy: 'time ASC',
    );

    return maps.map((map) => HourlyWeather(
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['time']),
      temperature: map['temperature'],
      rainProbability: map['rainProbability'].toDouble(),
      description: map['condition'],
      icon: '',
      windSpeed: map['windSpeed'],
    )).toList();
  }

  // Favorite Locations Operations
  Future<void> addFavoriteLocation(String city, {double? latitude, double? longitude}) async {
    final db = await database;
    await db.insert(
      _favoritesTable,
      {
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavoriteLocation(String city) async {
    final db = await database;
    await db.delete(
      _favoritesTable,
      where: 'city = ?',
      whereArgs: [city],
    );
  }

  Future<List<String>> getFavoriteLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _favoritesTable,
      orderBy: 'addedAt DESC',
    );

    return maps.map((map) => map['city'] as String).toList();
  }

  Future<bool> isFavoriteLocation(String city) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _favoritesTable,
      where: 'city = ?',
      whereArgs: [city],
    );

    return maps.isNotEmpty;
  }

  // Cache Management
  Future<bool> isCacheValid(String city, {Duration maxAge = const Duration(hours: 1)}) async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _currentWeatherTable,
      where: 'city = ? AND timestamp > ?',
      whereArgs: [city, cutoffTime],
    );

    return maps.isNotEmpty;
  }

  Future<void> clearOldCache({Duration maxAge = const Duration(days: 7)}) async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;

    await db.delete(_currentWeatherTable, where: 'timestamp < ?', whereArgs: [cutoffTime]);
    await db.delete(_forecastTable, where: 'timestamp < ?', whereArgs: [cutoffTime]);
    await db.delete(_hourlyWeatherTable, where: 'timestamp < ?', whereArgs: [cutoffTime]);
  }

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete(_currentWeatherTable);
    await db.delete(_forecastTable);
    await db.delete(_hourlyWeatherTable);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
