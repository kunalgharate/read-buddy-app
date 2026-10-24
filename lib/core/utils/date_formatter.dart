class DateFormatter {
  static const _monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static DateTime? parseRequestDateOnly(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    final datePart = s.split(RegExp(r'[\sT]')).first.split('-');
    if (datePart.length == 3) {
      final y = int.tryParse(datePart[0]);
      final m = int.tryParse(datePart[1]);
      final d = int.tryParse(datePart[2]);
      if (y == null || m == null || d == null) return null;
      if (m < 1 || m > 12 || d < 1 || d > 31) return null;

      // Validate that y/m/d is a real calendar date (e.g. 2024-02-31 is invalid)
      final testDt = DateTime(y, m, d);
      if (testDt.year != y || testDt.month != m || testDt.day != d) return null;

      return DateTime(y, m, d);
    }

    final dt = DateTime.tryParse(s);
    if (dt == null) return null;
    return DateTime(dt.year, dt.month, dt.day);
  }

  static String formatRequestDate(String? raw) {
    final date = parseRequestDateOnly(raw);
    if (date == null) {
      if (raw == null || raw.trim().isEmpty) return '—';
      return raw;
    }
    return '${date.day} ${_monthAbbr[date.month - 1]} ${date.year}';
  }

  static bool isDueOnOrBeforeToday(String? raw) {
    final due = parseRequestDateOnly(raw);
    if (due == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !due.isAfter(today);
  }
}
