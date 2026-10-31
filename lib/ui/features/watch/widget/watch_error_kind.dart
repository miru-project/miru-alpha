import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The watch failure taxonomy — every way an episode can fail to play, each
/// with its own diagnostics surface:
///
/// * [WatchErrorKind.extension] — the extension bridge itself failed (the
///   watch/mirror RPC threw). Always carries the STACK TRACE.
/// * [WatchErrorKind.mirror] — the V2 mirror list resolved but resolving the
///   chosen mirror failed ([WatchMirrorException]). Carries the fallback
///   mirrors ("Switch Mirror").
/// * [WatchErrorKind.videoRequest] — the stream request the video engine
///   (fvp) made returned non-200 (403 expired link, 404, 5xx) or the demuxer
///   failed. Surfaces the engine's verbatim error; Retry re-requests the
///   same URL, Switch Mirror re-requests another mirror's URL.
enum WatchErrorKind { extension, mirror, videoRequest }

/// A classified watch failure: category, one-line reason, the diagnostics
/// dump (extension errors carry the stack trace) and the fallback mirrors
/// when the V2 mirror list is known.
class WatchErrorInfo {
  const WatchErrorInfo({
    required this.kind,
    required this.message,
    required this.detail,
    this.mirrors = const [],
  });

  final WatchErrorKind kind;
  final String message;
  final String detail;
  final List<pb.ExtensionMirror> mirrors;

  /// The localized category label ("Extension error", "Video mirror
  /// error", "Video request error").
  String get categoryLabel => switch (kind) {
    WatchErrorKind.extension => 'watch.error_extension'.i18n,
    WatchErrorKind.mirror => 'watch.error_mirror'.i18n,
    WatchErrorKind.videoRequest => 'watch.error_video_request'.i18n,
  };

  /// Builds the video-request variant from the video engine's own error
  /// text (fvp's errorDescription — the HTTP status / demuxer message).
  factory WatchErrorInfo.videoRequest(String playerError) => WatchErrorInfo(
    kind: WatchErrorKind.videoRequest,
    message: playerError,
    detail: playerError,
  );
}

/// Classifies a watch-request failure into the taxonomy. The V2 mirror
/// failure keeps its fallback mirror list; every other extension-bridge
/// failure is an extension error and carries the stack trace.
WatchErrorInfo classifyWatchError(Object error, StackTrace trace) {
  if (error is WatchMirrorException) {
    final mirrors = [
      for (final group in error.v2watch.groups) ...group.mirrors,
    ];
    return WatchErrorInfo(
      kind: WatchErrorKind.mirror,
      message: error.cause.toString(),
      detail: '$error\n\n${trace.toString().split('\n').take(6).join('\n')}',
      mirrors: mirrors,
    );
  }
  final message = error.toString();
  final firstLine = message.contains('\n')
      ? message.substring(0, message.indexOf('\n'))
      : message;
  return WatchErrorInfo(
    kind: WatchErrorKind.extension,
    message: firstLine.length > 90 ? firstLine.substring(0, 90) : firstLine,
    detail: '$error\n\n${trace.toString().split('\n').take(6).join('\n')}',
  );
}
