import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_alpha/provider/network_provider.dart';
import 'package:miru_alpha/utils/core/log.dart';

/// Resolves a watch URL to the source the player should load, ONCE per url.
///
/// A multi-variant HLS master playlist collapses to its FIRST media
/// playlist: handing mdk/ffmpeg a master makes them probe EVERY variant on
/// open (all playlists + segments of each bitrate — ~5x the bandwidth and
/// seconds of start delay), while the app switches quality by URL itself.
/// Returns null while the resolve is in flight (one manifest round-trip —
/// the caller keeps the canvas black instead of opening the master);
/// failures fall back to the original url. Torrent / local playback passes
/// `null` and skips the resolve entirely.
PlaybackSource? useResolvedPlayback(String? url, Map<String, String> headers) {
  final resolved = useState<PlaybackSource?>(null);
  useEffect(() {
    if (url == null) return null;
    var cancelled = false;
    resolvePlayback(url, headers).then(
      (src) {
        if (!cancelled) resolved.value = src;
      },
      onError: (Object e) {
        logger.warning('playback resolve failed, loading as-is', e);
        if (!cancelled) {
          resolved.value = (
            qualityMap: <String, String>{'': url},
            playbackUrl: url,
          );
        }
      },
    );
    return () => cancelled = true;
  }, [url]);
  return resolved.value;
}
