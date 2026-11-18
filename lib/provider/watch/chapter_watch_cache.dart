import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/watch_result.dart';
import 'package:miru_alpha/provider/extension_provider.dart' show resolveWatch;

/// Resolved-watch cache shared by the watch session and the reader windows.
///
/// The webtoon window prefetches adjacent chapters as the reader scrolls and
/// flips the tracked chapter mid-session. Without a store every flip
/// re-issued the watch call and flipped the session to `AsyncLoading`, which
/// mounted the loading screen over the whole reader while the chapter
/// re-resolved. This is a small bounded LRU: only a handful of chapters are
/// ever near the viewport, so a six-entry cap is generous.
class WatchChapterCache {
  static const int maxEntries = 6;

  /// Insertion-order LRU: the most recently used entry is moved to the back;
  /// the oldest (front) is evicted once the cap is exceeded.
  static final Map<String, WatchResult> _entries = {};

  /// Overridable resolver so tests can count calls and avoid the network.
  /// Production uses [resolveWatch].
  static Future<WatchResult> Function({
    required String watchUrl,
    required String detailUrl,
    required ExtensionMeta meta,
    String? mirrorUrl,
  }) resolver = _defaultResolve;

  static Future<WatchResult> _defaultResolve({
    required String watchUrl,
    required String detailUrl,
    required ExtensionMeta meta,
    String? mirrorUrl,
  }) {
    return resolveWatch(
      watchUrl: watchUrl,
      detailUrl: detailUrl,
      meta: meta,
      mirrorUrl: mirrorUrl,
    );
  }

  static String _key(String watchUrl, String? mirrorUrl) =>
      '$watchUrl|${mirrorUrl ?? ''}';

  static WatchResult? peek(String watchUrl, {String? mirrorUrl}) {
    final key = _key(watchUrl, mirrorUrl);
    final hit = _entries.remove(key);
    if (hit == null) return null;
    _entries[key] = hit;
    return hit;
  }

  static Future<WatchResult> resolve({
    required String watchUrl,
    required String detailUrl,
    required ExtensionMeta meta,
    String? mirrorUrl,
  }) async {
    final key = _key(watchUrl, mirrorUrl);
    final hit = _entries.remove(key);
    if (hit != null) {
      _entries[key] = hit;
      return hit;
    }
    final result = await resolver(
      watchUrl: watchUrl,
      detailUrl: detailUrl,
      meta: meta,
      mirrorUrl: mirrorUrl,
    );
    _entries[key] = result;
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    return result;
  }

  static void clear() => _entries.clear();
}
