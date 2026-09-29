import 'package:miru_alpha/utils/core/i18n.dart';

/// Renders [date] as a coarse relative label ("just now", "3 days ago").
///
/// Extracted from the library and download cards, which each had their own
/// private copy, so the reader's chapter list can reuse one implementation
/// (rule: do not duplicate logic).
String formatTimeAgo(DateTime date) {
  final difference = DateTime.now().difference(date);

  if (difference.inMinutes < 1) {
    return 'common.just_now'.i18n;
  } else if (difference.inHours < 1) {
    return 'common.minutes_ago'.fill({
      'minutes': difference.inMinutes.toString(),
    });
  } else if (difference.inDays < 1) {
    return 'common.hours_ago'.fill({'hours': difference.inHours.toString()});
  } else if (difference.inDays == 1) {
    return 'common.yesterday'.i18n;
  } else if (difference.inDays < 7) {
    return 'common.days_ago'.fill({'days': difference.inDays.toString()});
  } else if (difference.inDays < 30) {
    return 'common.weeks_ago'.fill({
      'weeks': (difference.inDays / 7).floor().toString(),
    });
  } else if (difference.inDays < 365) {
    return 'common.months_ago'.fill({
      'months': (difference.inDays / 30).floor().toString(),
    });
  } else {
    return 'common.years_ago'.fill({
      'years': (difference.inDays / 365).floor().toString(),
    });
  }
}

/// Renders the backend's ISO timestamp as a short local date, falling back to
/// the raw string when it cannot be parsed.
String formatShortDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  final local = parsed.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

/// Best-effort relative label for a backend timestamp string.
///
/// Returns null when [raw] is empty or unparseable, so callers can fall back to
/// whatever else they have to show.
String? tryFormatTimeAgo(String raw) {
  if (raw.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  return formatTimeAgo(parsed.toLocal());
}
