import 'package:flutter/material.dart';

class OfflineIndicator extends StatelessWidget {
  final bool isOffline;
  final bool isFromCache;

  const OfflineIndicator({
    super.key,
    required this.isOffline,
    this.isFromCache = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && !isFromCache) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOffline 
            ? Colors.red.withOpacity(0.1) 
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOffline ? Colors.red : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOffline ? Icons.wifi_off : Icons.cached,
            size: 16,
            color: isOffline ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            isOffline ? 'Offline Mode' : 'Cached Data',
            style: TextStyle(
              color: isOffline ? Colors.red : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
