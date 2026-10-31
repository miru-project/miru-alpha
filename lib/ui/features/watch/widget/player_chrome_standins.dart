import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The transient watch states' (loading / error) player chrome, built from
/// THE LOADED PLAYER'S atoms and geometry — the user directive: the watch
/// page is the product, so every transient state keeps tight to the normal
/// watch UI in portrait and landscape. Same scrim gradient, same top-bar
/// structure, same scrubber section, same chips and buttons; controls that
/// cannot work without a stream render dimmed and inert.

/// The loaded player's overlay scrim, per orientation (the landscape dock's
/// gradient is stronger — reference mock + contrast review).
class PlayerChromeScrim extends StatelessWidget {
  const PlayerChromeScrim({super.key, required this.landscape});

  final bool landscape;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: landscape ? [0, 0.22, 0.5, 0.62, 1] : [0, 0.18, 0.5, 0.62, 1],
          colors: landscape
              ? [
                  const Color(0xE6000000),
                  const Color(0x80000000),
                  const Color(0x1A000000),
                  Colors.transparent,
                  const Color(0xF2000000),
                ]
              : [
                  const Color(0xB3000000),
                  const Color(0x73000000),
                  const Color(0x1A000000),
                  Colors.transparent,
                  const Color(0xE6000000),
                ],
        ),
      ),
    );
  }
}

/// A dimmed, inert shell for a loaded-chrome control that cannot work
/// without a stream (cast, chips, fullscreen on the transient states).
class PlayerInertShell extends StatelessWidget {
  const PlayerInertShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AbsorbPointer(child: Opacity(opacity: 0.35, child: child)),
    );
  }
}

/// Portrait top row — the loaded chrome's exact structure (back · centered
/// "Now Playing"/title stack · cast), with the cast inert while no stream
/// plays. The transient states add no extra buttons: the loaded bar has
/// none to mirror.
class PlayerTopBarStandIn extends StatelessWidget {
  const PlayerTopBarStandIn({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The page's 16px gutter applies to the player chrome too (user
      // directive) — the canvas itself stays full-bleed.
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          PlayerCircleButton(
            onPress: onBack,
            semanticLabel: 'common.back'.i18n,
            icon: const Icon(FLucideIcons.chevronLeft, size: 20),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'watch.now_playing'.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The loaded row's trailing cluster 1:1: auto-rotation toggle
          // (resting = the off glyph) then cast — both inert while no
          // stream plays.
          PlayerInertShell(
            child: PlayerCircleButton(
              onPress: null,
              semanticLabel: '',
              icon: const Icon(FLucideIcons.refreshCwOff, size: 18),
            ),
          ),
          PlayerInertShell(
            child: PlayerCircleButton(
              small: true,
              onPress: null,
              semanticLabel: '',
              icon: const Icon(FLucideIcons.cast, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// Portrait bottom bar — the loaded scrubber section's geometry 1:1
/// (16px touch box over the slim track, 1px gap, then the meta row with
/// the speed chip and the 28px fullscreen button), inert because no
/// stream exists yet.
class PlayerBottomBarStandIn extends StatelessWidget {
  const PlayerBottomBarStandIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Column(
        children: [
          SizedBox(
            height: 16,
            child: Center(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Row(
            children: [
              Text(
                '00:00 / --:--',
                style: TextStyle(
                  color: Colors.white.withAlpha(230),
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              PlayerInertShell(
                child: PlayerMetaChip(label: '1.0x', onPress: () {}),
              ),
              const SizedBox(width: 6),
              PlayerInertShell(
                child: FButton.icon(
                  variant: .ghost,
                  onPress: null,
                  style: .delta(
                    iconContentStyle: .delta(
                      padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ),
                  child: const Icon(FLucideIcons.maximize, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Landscape header — the loaded dock header's structure (back ·
/// left-anchored title block · cast), inert cast, no extra buttons.
class PlayerLandscapeHeaderStandIn extends StatelessWidget {
  const PlayerLandscapeHeaderStandIn({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 0),
      child: Row(
        children: [
          PlayerCircleButton(
            onPress: onBack,
            semanticLabel: 'common.back'.i18n,
            icon: const Icon(FLucideIcons.chevronLeft, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'watch.now_playing'.i18n,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // The loaded header's trailing cluster 1:1: auto-rotation (full
          // 44px rhythm in the dock header) then cast — both inert.
          PlayerInertShell(
            child: PlayerCircleButton(
              onPress: null,
              semanticLabel: '',
              icon: const Icon(FLucideIcons.refreshCwOff, size: 18),
            ),
          ),
          const SizedBox(width: 2),
          PlayerInertShell(
            child: PlayerCircleButton(
              small: true,
              onPress: null,
              semanticLabel: '',
              icon: const Icon(FLucideIcons.cast, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// Landscape bottom dock — the loaded dock's transport rows with inert
/// controls: the flanking-timestamp scrubber row, then the play · spacer ·
/// chip · fullscreen cluster.
class PlayerLandscapeDockStandIn extends StatelessWidget {
  const PlayerLandscapeDockStandIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '00:00',
                style: TextStyle(
                  color: Colors.white.withAlpha(230),
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: SizedBox(
                  height: 16,
                  child: Center(child: StandInTrack()),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '--:--',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PlayerInertShell(
                child: PlayerCircleButton(
                  onPress: null,
                  semanticLabel: '',
                  small: true,
                  icon: const Icon(FLucideIcons.play, size: 14),
                ),
              ),
              const Spacer(),
              PlayerInertShell(
                child: PlayerMetaChip(label: '1.0x', onPress: () {}),
              ),
              const SizedBox(width: 6),
              PlayerInertShell(
                child: PlayerCircleButton(
                  onPress: null,
                  semanticLabel: '',
                  small: true,
                  icon: const Icon(FLucideIcons.maximize, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The slim seek line's stand-in — the SeekBar's resting geometry without
/// the widget (there is no player to bind).
class StandInTrack extends StatelessWidget {
  const StandInTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(35),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
