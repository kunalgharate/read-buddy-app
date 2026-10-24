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

  static bool _hasUtcOffset(String s) {
    return RegExp(r'[\sT].*[+-]\d{2}:?\d{2}$').hasMatch(s);
  }

  static DateTime? parseRequestDateOnly(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s);
    if (dt == null) return null;

    final datePart = s.split(RegExp(r'[\sT]')).first.split('-');
    if (datePart.length == 3) {
      final y = int.tryParse(datePart[0]);
      final m = int.tryParse(datePart[1]);
      final d = int.tryParse(datePart[2]);
      if (y != null && m != null && d != null) {
        if (m < 1 || m > 12 || d < 1 || d > 31) return null;
      }
    }

    if (s.endsWith('Z') || s.endsWith('z')) {
      final utc = dt.toUtc();
      return DateTime(utc.year, utc.month, utc.day);
    }
    if (_hasUtcOffset(s)) {
      final parts = s.split(RegExp(r'[\sT]')).first.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          if (m < 1 || m > 12 || d < 1 || d > 31) return null;
          return DateTime(y, m, d);
        }
      }
    }
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
