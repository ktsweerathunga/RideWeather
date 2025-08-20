import 'package:flutter/material.dart';
import '../../../providers/weather_provider.dart';
import '../../../core/constants.dart';
import '../../../core/app_routes.dart';

class QuickActionsCard extends StatelessWidget {
  final WeatherProvider weatherProvider;

  const QuickActionsCard({
    super.key,
    required this.weatherProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Location Toggle
            _ActionTile(
              icon: weatherProvider.isUsingCurrentLocation 
                  ? Icons.location_on 
                  : Icons.location_city,
              title: weatherProvider.isUsingCurrentLocation 
                  ? 'Using Current Location' 
                  : 'Using Selected City',
              subtitle: weatherProvider.selectedCity,
              onTap: () => weatherProvider.toggleLocationMode(),
              trailing: Switch(
                value: weatherProvider.isUsingCurrentLocation,
                onChanged: (_) => weatherProvider.toggleLocationMode(),
                activeColor: AppConstants.primaryBlue,
              ),
            ),
            
            const Divider(),
            
            // Notifications Toggle
            _ActionTile(
              icon: weatherProvider.notificationsEnabled 
                  ? Icons.notifications_active 
                  : Icons.notifications_off,
              title: 'Morning Rain Alerts',
              subtitle: weatherProvider.notificationsEnabled 
                  ? 'Enabled' 
                  : 'Disabled',
              onTap: () => weatherProvider.toggleNotifications(),
              trailing: Switch(
                value: weatherProvider.notificationsEnabled,
                onChanged: (_) => weatherProvider.toggleNotifications(),
                activeColor: AppConstants.primaryBlue,
              ),
            ),
            
            const Divider(),
            
            // Search Cities
            _ActionTile(
              icon: Icons.search,
              title: 'Search Other Cities',
              subtitle: 'Find weather in other Sri Lankan cities',
              onTap: () => AppRoutes.navigateToSearch(context),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppConstants.textGray,
              ),
            ),
            
            const Divider(),
            
            // View Forecast
            _ActionTile(
              icon: Icons.calendar_today,
              title: '7-Day Forecast',
              subtitle: 'View extended weather forecast',
              onTap: () => AppRoutes.navigateToForecast(context),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppConstants.textGray,
              ),
            ),
            
            // Last Updated Info
            if (weatherProvider.lastUpdated != null) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Center(
                child: Text(
                  'Last updated: ${_formatLastUpdated(weatherProvider.lastUpdated!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: AppConstants.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                icon,
                color: AppConstants.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
