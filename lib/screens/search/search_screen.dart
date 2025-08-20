import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../core/constants.dart';
import '../../core/app_routes.dart';
import 'widgets/location_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = AppConstants.sriLankanCities;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _filteredCities = AppConstants.sriLankanCities
          .where((city) => city.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _filteredCities = AppConstants.sriLankanCities;
    });
  }

  Future<void> _selectCity(String cityName) async {
    final weatherProvider = context.read<WeatherProvider>();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await weatherProvider.setSelectedCity(cityName);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        AppRoutes.navigateBack(context); // Go back to home
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading weather for $cityName'),
            backgroundColor: AppConstants.rainRed,
          ),
        );
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    final weatherProvider = context.read<WeatherProvider>();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await weatherProvider.fetchWeatherByLocation();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        AppRoutes.navigateBack(context); // Go back to home
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error getting current location weather'),
            backgroundColor: AppConstants.rainRed,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => weatherProvider.openLocationSettings(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Header
          Container(
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
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Sri Lankan cities...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppConstants.primaryBlue,
                      ),
                      suffixIcon: _isSearching
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppConstants.textGray,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingMedium,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),
                
                // Current Location Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.clearGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Cities List
          Expanded(
            child: Consumer<WeatherProvider>(
              builder: (context, weatherProvider, child) {
                if (_filteredCities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppConstants.textGray.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'No cities found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppConstants.textGray,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Try searching for a different city',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: _filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = _filteredCities[index];
                    final isSelected = city == weatherProvider.selectedCity && 
                                     !weatherProvider.isUsingCurrentLocation;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                      child: LocationTile(
                        cityName: city,
                        isSelected: isSelected,
                        onTap: () => _selectCity(city),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
