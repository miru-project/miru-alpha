/// Display-layer cleanup for scraped release names ("[ToonsHub] Daemons of
/// the Shadow Realm S01E17 1080p NF WEB-DL AAC2.0 H.264 (...)" reads as
/// "Daemons of the Shadow Realm S01E17"). Display only — the raw string
/// stays in the database and detail pages.
library;

// Scraped release names carry group tags and site prefixes anywhere:
// "[Group] Show S01E17 1080p ..." and "Watch [Group] Show S01E17 ...".
final _junkSegments = RegExp(r'\[[^\]]*\]|\([^)]*\)');
final _leadingWatch = RegExp(r'^watch\s+', caseSensitive: false);
final _qualityToken = RegExp(
  r'\s(1080p|720p|2160p|480p|4K|WEB-?DL|WEBRip|WEB\s|BluRay|BDRip|HDTV|'
  r'HEVC|AVC|x26[45]|H\.?26[45]|AAC2?\.?0?|FLAC|DTS|DDP?|AC3|10bit|'
  r'NF|CR|DSNP|AMZN|HULU|MAX|MULTI|DUAL)(\s|\[|\(|$)',
  caseSensitive: false,
);
final _trailingJunk = RegExp(r'[\s\-–—.]+\s*$');
final _doubleSpace = RegExp(r'\s{2,}');

/// Returns [raw] with bracket/paren segment tags stripped, everything from
/// the first quality/codec token onward dropped, and a leading "Watch "
/// site prefix removed. Falls back to the raw string when nothing
/// recognisable remains.
String displayTitle(String raw) {
  var t = raw.trim().replaceAll(_junkSegments, ' ');
  final m = _qualityToken.firstMatch(t);
  if (m != null && m.start > 3) t = t.substring(0, m.start);
  t = t.replaceAll(_leadingWatch, '');
  t = t.replaceAll(_trailingJunk, '').replaceAll(_doubleSpace, ' ').trim();
  return t.isEmpty ? raw.trim() : t;
}
