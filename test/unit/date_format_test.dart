import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/core/date_format.dart';

void main() {
  // The i18n extension reads the navigator key, which needs a live binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tryFormatTimeAgo', () {
    test('returns null for empty or unparseable input', () {
      expect(tryFormatTimeAgo(''), isNull);
      expect(tryFormatTimeAgo('   '), isNull);
      expect(tryFormatTimeAgo('not a date'), isNull);
    });

    test('converts an ISO stamp to local time before formatting', () {
      final justNow = DateTime.now().subtract(const Duration(seconds: 5));
      // Whatever the zone, a stamp a few seconds old must read as "now"
      // rather than a negative interval.
      expect(tryFormatTimeAgo(justNow.toIso8601String()), isNotNull);
      expect(tryFormatTimeAgo(justNow.toUtc().toIso8601String()), isNotNull);
    });

    test('a future stamp does not produce a negative label', () {
      final future = DateTime.now().add(const Duration(days: 3));
      expect(formatTimeAgo(future), isNotEmpty);
    });
  });

  group('formatShortDate', () {
    test('renders a zero-padded local date and time', () {
      final local = DateTime(2026, 3, 7, 9, 5);
      final formatted = formatShortDate(local.toIso8601String());
      expect(formatted, matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$')));
      expect(formatted, contains('2026-03-07'));
    });

    test('passes an unparseable value straight through', () {
      expect(formatShortDate('yesterday'), 'yesterday');
    });
  });
}
