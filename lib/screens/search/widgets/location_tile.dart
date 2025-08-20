import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class LocationTile extends StatelessWidget {
  final String cityName;
  final bool isSelected;
  final VoidCallback onTap;

  const LocationTile({
    super.key,
    required this.cityName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: isSelected 
              ? Border.all(color: AppConstants.primaryBlue, width: 2)
              : null,
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingSmall,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppConstants.primaryBlue
                  : AppConstants.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              Icons.location_city,
              color: isSelected ? Colors.white : AppConstants.primaryBlue,
              size: 20,
            ),
          ),
          title: Text(
            cityName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppConstants.primaryBlue : AppConstants.textDark,
            ),
          ),
          subtitle: Text(
            'Sri Lanka',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.textGray,
            ),
          ),
          trailing: isSelected
              ? Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              : Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppConstants.textGray.withOpacity(0.5),
                ),
        ),
      ),
    );
  }
}
