/// The seam between the app player and the DLNA cast session.
///
/// [DlnaPlayerSurface] is the SIMPLIFIED player contract the cast session
/// drives in BOTH directions: app-side actions (play/pause/seek/episode
/// switch) are forwarded to the renderer, and the renderer's own transport
/// state (TV remote) is echoed back onto the surface. The production
/// player notifier implements it; tests use a scripted fake.
library;

/// The app-side player as the cast session sees it.
abstract class DlnaPlayerSurface {
  /// App-side play — forwarded to the renderer.
  void play();

  /// App-side pause — forwarded to the renderer.
  void pause();

  /// App-side seek — forwarded to the renderer (native stream seek + re-push).
  void seekTo(Duration position);

  /// Episode/source switch — a fresh SetAVTransportURI push.
  Future<void> load(String source);

  /// The player's current playback position (app master clock).
  Duration get position;

  /// The loaded media's duration, null when unknown.
  Duration? get duration;

  /// Whether the player is (nominally) playing.
  bool get playing;

  /// RENDERER→app echo only: aligns the player's displayed position/state
  /// with the renderer without re-triggering forwarding (the reverse half
  /// of the two-way sync).
  void syncTransport({required bool playing, required Duration position});
}

/// Pipes local-player commands to the DLNA renderer while a cast session is
/// live, and renderer events back onto the player.
///
/// The player notifier only ever talks to this plain singleton — no Riverpod
/// dependency leaks into the player, and handler errors never break local
/// playback.
class DlnaCastBridge {
  DlnaCastBridge._();

  static final DlnaCastBridge instance = DlnaCastBridge._();

  DlnaPlayerSurface? _surface;
  void Function()? _onRemotePlay;
  void Function()? _onRemotePause;
  void Function(Duration position)? _onRemotePosition;
  void Function()? _onRemoteEnded;

  /// True while a cast session is connected and forwarding.
  bool get active => _surface != null;

  /// Called by the [DlnaCast] provider when a renderer connects. The
  /// surface receives app→renderer forwarding; the callbacks receive
  /// renderer→app events.
  void attach({
    required DlnaPlayerSurface surface,
    required void Function() onRemotePlay,
    required void Function() onRemotePause,
    required void Function(Duration position) onRemotePosition,
    required void Function() onRemoteEnded,
  }) {
    _surface = surface;
    _onRemotePlay = onRemotePlay;
    _onRemotePause = onRemotePause;
    _onRemotePosition = onRemotePosition;
    _onRemoteEnded = onRemoteEnded;
  }

  /// Called on disconnect/dispose — the player keeps playing locally.
  void detach() {
    _surface = null;
    _onRemotePlay = null;
    _onRemotePause = null;
    _onRemotePosition = null;
    _onRemoteEnded = null;
  }

  DlnaPlayerSurface? get surface => _surface;

  /// The local player started playing.
  void pipePlay() {
    final handler = _onRemotePlay;
    if (handler == null) return;
    try {
      handler();
    } catch (_) {}
  }

  /// The local player was paused.
  void pipePause() {
    final handler = _onRemotePause;
    if (handler == null) return;
    try {
      handler();
    } catch (_) {}
  }

  /// The local player seeked — forwarded as a renderer seek/re-push.
  void pipeSeek(Duration position) {
    final handler = _onRemotePosition;
    if (handler == null) return;
    try {
      handler(position);
    } catch (_) {}
  }

  /// The renderer's position moved (or was corrected).
  void pipeRemotePosition(Duration position) {
    final handler = _onRemotePosition;
    if (handler == null) return;
    try {
      handler(position);
    } catch (_) {}
  }

  /// The renderer reported STOPPED (stream end / renderer-initiated stop).
  void pipeRemoteEnded() {
    final handler = _onRemoteEnded;
    if (handler == null) return;
    try {
      handler();
    } catch (_) {}
  }
}
