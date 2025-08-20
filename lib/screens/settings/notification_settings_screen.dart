import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../services/location_service.dart';
import '../../widgets/neumorphic_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 6, minute: 0);
  String _selectedCity = 'Colombo';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final enabled = await NotificationService.areNotificationsEnabled();
      final timePrefs = await NotificationService.getNotificationTime();
      final city = await NotificationService.getSelectedCityForNotifications();
      
      setState(() {
        _notificationsEnabled = enabled;
        _notificationTime = TimeOfDay(
          hour: timePrefs['hour']!,
          minute: timePrefs['minute']!,
        );
        _selectedCity = city;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    if (enabled) {
      final hasPermission = await NotificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    await NotificationService.setNotificationsEnabled(enabled);
    setState(() => _notificationsEnabled = enabled);

    if (enabled) {
      await NotificationService.scheduleDailyMorningRainCheck();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled 
              ? 'Morning rain alerts enabled' 
              : 'Notifications disabled'),
          backgroundColor: enabled ? Colors.green : Colors.grey,
        ),
      );
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).cardColor,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _notificationTime) {
      setState(() => _notificationTime = picked);
      await NotificationService.setNotificationTime(picked.hour, picked.minute);
      
      if (_notificationsEnabled) {
        await NotificationService.scheduleDailyMorningRainCheck();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification time updated to ${picked.format(context)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _selectCity() async {
    final cities = LocationService.sriLankanCities;
    
    final String? selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select City'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                title: Text(city),
                leading: Radio<String>(
                  value: city,
                  groupValue: _selectedCity,
                  onChanged: (value) => Navigator.of(context).pop(value),
                ),
                onTap: () => Navigator.of(context).pop(city),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null && selected != _selectedCity) {
      setState(() => _selectedCity = selected);
      await NotificationService.setSelectedCityForNotifications(selected);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification city updated to $selected'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.sendTestNotification();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NeumorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Morning Rain Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get notified about rain during your morning commute',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Daily morning weather alerts'),
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          if (_notificationsEnabled) ...[
            const SizedBox(height: 16),
            NeumorphicCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Color(0xFF3B82F6)),
                    title: const Text('Notification Time'),
                    subtitle: Text(_notificationTime.format(context)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectTime,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_city, color: Color(0xFF10B981)),
                    title: const Text('City'),
                    subtitle: Text(_selectedCity),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectCity,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            NeumorphicCard(
              child: ListTile(
                leading: const Icon(Icons.notifications_active, color: Color(0xFFFBBF24)),
                title: const Text('Test Notification'),
                subtitle: const Text('Send a test notification now'),
                trailing: ElevatedButton(
                  onPressed: _sendTestNotification,
                  child: const Text('Send'),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          NeumorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How it works',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  icon: Icons.schedule,
                  title: 'Daily Check',
                  description: 'We check the weather at your selected time',
                ),
                const SizedBox(height: 8),
                _buildInfoItem(
                  icon: Icons.grain,
                  title: 'Rain Detection',
                  description: 'If rain is likely (>60%), you\'ll get an alert',
                ),
                const SizedBox(height: 8),
                _buildInfoItem(
                  icon: Icons.motorcycle,
                  title: 'Ride Smart',
                  description: 'Plan your commute based on weather conditions',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
