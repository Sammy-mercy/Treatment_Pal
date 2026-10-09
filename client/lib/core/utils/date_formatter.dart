// core/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatTimestamp(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM d · hh:mm a').format(date);
    } catch (_) {
      return isoString;
    }
  }
}
