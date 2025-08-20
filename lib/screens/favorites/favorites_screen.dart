import 'package:flutter/material.dart';
import '../../services/offline_weather_service.dart';
import '../../widgets/custom_weather_icons.dart';
import '../../widgets/neumorphic_card.dart';
import '../../models/weather_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final OfflineWeatherService _offlineService = OfflineWeatherService();
  List<String> _favorites = [];
  Map<String, CurrentWeather?> _weatherData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    try {
      final favorites = await _offlineService.getFavoriteLocations();
      setState(() => _favorites = favorites);
      
      // Load weather data for each favorite
      for (final city in favorites) {
        final weather = await _offlineService.getCurrentWeather(city);
        setState(() => _weatherData[city] = weather);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(String city) async {
    try {
      await _offlineService.removeFavoriteLocation(city);
      setState(() {
        _favorites.remove(city);
        _weatherData.remove(city);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$city removed from favorites'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _addFavorite(city),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing favorite: $e')),
        );
      }
    }
  }

  Future<void> _addFavorite(String city) async {
    try {
      await _offlineService.addFavoriteLocation(city);
      await _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding favorite: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final city = _favorites[index];
                      final weather = _weatherData[city];
                      return _buildFavoriteCard(city, weather);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorite Locations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add cities to your favorites from the search screen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: const Icon(Icons.search),
            label: const Text('Search Cities'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(String city, CurrentWeather? weather) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicCard(
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/weather-detail',
            arguments: city,
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Weather icon
                if (weather != null)
                  CustomWeatherIcons.getWeatherIcon(
                    weather.condition,
                    size: 40,
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_off, color: Colors.grey),
                  ),
                
                const SizedBox(width: 16),
                
                // City and weather info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (weather != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${weather.temperature.toInt()}°C • ${weather.condition}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Humidity: ${weather.humidity}% • Wind: ${weather.windSpeed.toInt()} km/h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text(
                          'Weather data unavailable',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Temperature and actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (weather != null)
                      Text(
                        '${weather.temperature.toInt()}°',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    const SizedBox(height: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'remove') {
                          _removeFavorite(city);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Remove'),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
