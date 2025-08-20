import 'package:intl/intl.dart';

class AppDateUtils {
  // Format date for display
  static String formatDate(DateTime date, {String pattern = 'MMM d, yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  // Format time for display
  static String formatTime(DateTime dateTime, {bool use24Hour = false}) {
    final pattern = use24Hour ? 'HH:mm' : 'h:mm a';
    return DateFormat(pattern).format(dateTime);
  }

  // Format date and time together
  static String formatDateTime(DateTime dateTime, {bool use24Hour = false}) {
    final datePattern = 'MMM d, yyyy';
    final timePattern = use24Hour ? 'HH:mm' : 'h:mm a';
    return '${formatDate(dateTime, pattern: datePattern)} at ${formatTime(dateTime, use24Hour: use24Hour)}';
  }

  // Get relative time (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      // Past time
      final absDifference = difference.abs();
      
      if (absDifference.inMinutes < 1) {
        return 'Just now';
      } else if (absDifference.inMinutes < 60) {
        return '${absDifference.inMinutes} minutes ago';
      } else if (absDifference.inHours < 24) {
        return '${absDifference.inHours} hours ago';
      } else if (absDifference.inDays < 7) {
        return '${absDifference.inDays} days ago';
      } else {
        return formatDate(dateTime);
      }
    } else {
      // Future time
      if (difference.inMinutes < 1) {
        return 'Now';
      } else if (difference.inMinutes < 60) {
        return 'In ${difference.inMinutes} minutes';
      } else if (difference.inHours < 24) {
        return 'In ${difference.inHours} hours';
      } else if (difference.inDays < 7) {
        return 'In ${difference.inDays} days';
      } else {
        return formatDate(dateTime);
      }
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  // Get day name with relative context
  static String getDayName(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isTomorrow(date)) return 'Tomorrow';
    if (isYesterday(date)) return 'Yesterday';
    return DateFormat('EEEE').format(date);
  }

  // Check if time is in morning hours (5 AM - 9 AM)
  static bool isMorningHour(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= 5 && hour <= 9;
  }

  // Get morning hours for a specific date
  static List<DateTime> getMorningHours(DateTime date) {
    final morningHours = <DateTime>[];
    for (int hour = 5; hour <= 9; hour++) {
      morningHours.add(DateTime(date.year, date.month, date.day, hour));
    }
    return morningHours;
  }

  // Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get time until next morning (5 AM)
  static Duration getTimeUntilMorning() {
    final now = DateTime.now();
    var nextMorning = DateTime(now.year, now.month, now.day, 5);
    
    // If it's already past 5 AM today, get tomorrow's 5 AM
    if (now.hour >= 5) {
      nextMorning = nextMorning.add(const Duration(days: 1));
    }
    
    return nextMorning.difference(now);
  }
}
