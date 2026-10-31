import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter.parseRequestDateOnly', () {
    test('returns null for null, empty, or blank strings', () {
      expect(DateFormatter.parseRequestDateOnly(null), isNull);
      expect(DateFormatter.parseRequestDateOnly(''), isNull);
      expect(DateFormatter.parseRequestDateOnly('   '), isNull);
    });

    test('returns null for unparseable or impossible calendar dates', () {
      expect(DateFormatter.parseRequestDateOnly('not-a-date'), isNull);
      expect(DateFormatter.parseRequestDateOnly('2026-99-99'), isNull);
      expect(DateFormatter.parseRequestDateOnly('2024-02-31'), isNull);
      expect(DateFormatter.parseRequestDateOnly('2026-10-20 garbage'), isNull);
      expect(DateFormatter.parseRequestDateOnly('05-12-25'), isNull);
    });

    test('parses date-only string YYYY-MM-DD correctly', () {
      final result = DateFormatter.parseRequestDateOnly('2026-10-20');
      expect(result, equals(DateTime(2026, 10, 20)));
    });

    test('parses UTC Z ISO-8601 string correctly', () {
      final result =
          DateFormatter.parseRequestDateOnly('2026-10-20T00:00:00.000Z');
      expect(result, equals(DateTime(2026, 10, 20)));
    });

    test('parses offset timestamp with T separator correctly', () {
      final result =
          DateFormatter.parseRequestDateOnly('2024-03-15T23:00:00-05:00');
      expect(result, equals(DateTime(2024, 3, 15)));
    });

    test('parses offset timestamp with space separator correctly', () {
      final result =
          DateFormatter.parseRequestDateOnly('2024-03-15 23:00:00-05:00');
      expect(result, equals(DateTime(2024, 3, 15)));
    });
  });

  group('DateFormatter.formatRequestDate', () {
    test('returns dash for null, empty, or blank strings', () {
      expect(DateFormatter.formatRequestDate(null), equals('—'));
      expect(DateFormatter.formatRequestDate(''), equals('—'));
      expect(DateFormatter.formatRequestDate('   '), equals('—'));
    });

    test('returns original string when date cannot be parsed', () {
      expect(DateFormatter.formatRequestDate('invalid'), equals('invalid'));
    });

    test('formats parseable date string into D MMM YYYY', () {
      expect(
        DateFormatter.formatRequestDate('2026-10-20'),
        equals('20 Oct 2026'),
      );
      expect(
        DateFormatter.formatRequestDate('2026-01-05T00:00:00Z'),
        equals('5 Jan 2026'),
      );
    });
  });
}
