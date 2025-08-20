import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      throw Exception('Error getting location: $e');
    }
  }

  // Get distance between two points in kilometers
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert to kilometers
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  static const List<String> sriLankanCities = [
    'Colombo', 'Kandy', 'Galle', 'Jaffna', 'Negombo', 'Anuradhapura',
    'Polonnaruwa', 'Batticaloa', 'Trincomalee', 'Matara', 'Ratnapura',
    'Badulla', 'Kurunegala', 'Puttalam', 'Kalutara', 'Gampaha',
    'Nuwara Eliya', 'Hambantota', 'Vavuniya', 'Chilaw'
  ];

  Future<String?> getCityFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String? city = placemarks.first.locality ?? placemarks.first.administrativeArea;
        
        // Check if it's a known Sri Lankan city
        if (city != null) {
          for (String sriLankanCity in sriLankanCities) {
            if (city.toLowerCase().contains(sriLankanCity.toLowerCase()) ||
                sriLankanCity.toLowerCase().contains(city.toLowerCase())) {
              return sriLankanCity;
            }
          }
        }
        return city ?? 'Unknown Location';
      }
      return null;
    } catch (e) {
      throw Exception('Error getting city name: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentLocationWithCity() async {
    try {
      Position? position = await getCurrentPosition();
      if (position != null) {
        String? city = await getCityFromCoordinates(position.latitude, position.longitude);
        return {
          'position': position,
          'city': city ?? 'Unknown Location',
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Error getting location with city: $e');
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await PermissionHandler().openAppSettings();
  }
}
