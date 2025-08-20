import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  
  const LocationPermissionDialog({
    super.key,
    this.onPermissionGranted,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(Icons.location_on, color: Color(0xFF3B82F6)),
          SizedBox(width: 10),
          Text('Location Access'),
        ],
      ),
      content: const Text(
        'RideDry needs location access to provide accurate weather information for your area. This helps us give you precise morning rain alerts for your commute.',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final locationService = LocationService();
            try {
              await locationService.getCurrentPosition();
              onPermissionGranted?.call();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Location access denied: ${e.toString()}'),
                    action: SnackBarAction(
                      label: 'Settings',
                      onPressed: () => locationService.openAppSettings(),
                    ),
                  ),
                );
              }
            }
          },
          child: const Text('Allow Access'),
        ),
      ],
    );
  }
}
