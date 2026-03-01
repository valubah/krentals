// lib/core/utils/date_utils.dart

import 'package:intl/intl.dart';

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});
}

class BookingDateUtils {
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static bool doesRangeOverlapBlocked(
    DateTime start,
    DateTime end,
    List<DateRange> blockedRanges,
  ) {
    // Convert to dates without time for accurate comparison
    final selStart = DateTime(start.year, start.month, start.day);
    final selEnd = DateTime(end.year, end.month, end.day);

    for (var b in blockedRanges) {
      final bStart = DateTime(b.start.year, b.start.month, b.start.day);
      final bEnd = DateTime(b.end.year, b.end.month, b.end.day);

      // Check for overlap: selection starts before blocked ends AND selection ends after blocked starts
      if (selStart.isBefore(bEnd) && selEnd.isAfter(bStart)) {
        return true;
      }
      // If edges touch (e.g. checkout on same day as next person checks in),
      // usually it's fine, but let's depend on precise requirement.
      // Assuming overlapping day means conflict.
      if (selStart == bStart ||
          selStart == bEnd ||
          selEnd == bStart ||
          selEnd == bEnd) {
        return true;
      }
    }
    return false;
  }

  static bool isDateBlocked(DateTime date, List<DateRange> blockedRanges) {
    final selDate = DateTime(date.year, date.month, date.day);
    for (var b in blockedRanges) {
      final bStart = DateTime(b.start.year, b.start.month, b.start.day);
      final bEnd = DateTime(b.end.year, b.end.month, b.end.day);
      if ((selDate.isAfter(bStart) || selDate.isAtSameMomentAs(bStart)) &&
          (selDate.isBefore(bEnd) || selDate.isAtSameMomentAs(bEnd))) {
        return true;
      }
    }
    return false;
  }

  static String toDisplay(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }
}
