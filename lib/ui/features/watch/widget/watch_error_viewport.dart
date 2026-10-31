import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:miru_alpha/ui/features/watch/widget/player_chrome_standins.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_details_dialog.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The 16:9 error canvas of the mobile watch page — the mock's "playback
/// interrupted" state: degraded error wash, the interruption card with
/// Retry / Switch Mirror, and a dead scrubber row. Every control that
/// cannot work without a stream (cast, settings, speed, fullscreen)
/// renders as a dimmed disabled shell.
class WatchErrorViewport extends HookWidget {
  const WatchErrorViewport({
    super.key,
    required this.title,
    required this.onBack,
    required this.onRetry,
    this.mirrors = const [],
    this.onSelectMirror,
    this.categoryLabel,
    this.detailText,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  /// Fallback mirrors the failure surfaced (V2 watch): non-empty enables
  /// the "Switch Mirror" control, empty keeps it out — a mirror switcher
  /// with no mirrors to switch to is a dead control.
  final List<pb_extension.ExtensionMirror> mirrors;
  final ValueChanged<String>? onSelectMirror;

  /// The failure's taxonomy label ("Extension error" / "Video mirror
  /// error" / "Video request error") — badged above the headline.
  final String? categoryLabel;

  /// The full diagnostics dump (message, stack trace or mirror list) the
  /// in-player "Error details" dialog shows and copies to the clipboard.
  final String? detailText;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder, not MediaQuery.sizeOf: branch on the REAL canvas
    // constraints (the test harness resizes via setSurfaceSize, which does
    // not refresh view metrics — rule 27).
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;
        final card = _InterruptionCard(
          onRetry: onRetry,
          mirrors: mirrors,
          onSelectMirror: onSelectMirror,
          categoryLabel: categoryLabel,
          detailText: detailText,
        );
        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFF0E0E0E)),
              // The loaded player's scrim (per orientation) — the
              // interruption card carries the error identity; the chrome
              // stays the watch's.
              PlayerChromeScrim(landscape: landscape),
              SafeArea(
                top: !landscape,
                bottom: false,
                child: landscape
                    ? Column(
                        children: [
                          PlayerLandscapeHeaderStandIn(
                            title: title,
                            onBack: onBack,
                          ),
                          Expanded(child: Center(child: card)),
                          const PlayerLandscapeDockStandIn(),
                        ],
                      )
                    : Column(
                        children: [
                          PlayerTopBarStandIn(title: title, onBack: onBack),
                          Expanded(child: Center(child: card)),
                          const PlayerBottomBarStandIn(),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InterruptionCard extends StatelessWidget {
  const _InterruptionCard({
    required this.onRetry,
    required this.mirrors,
    required this.onSelectMirror,
    this.categoryLabel,
    this.detailText,
  });

  final VoidCallback onRetry;
  final List<pb_extension.ExtensionMirror> mirrors;
  final ValueChanged<String>? onSelectMirror;

  /// The failure's taxonomy label ("Extension error" / "Video mirror
  /// error" / "Video request error") — badged above the headline.
  final String? categoryLabel;

  /// The diagnostics dump surfaced by the "Error details" dialog.
  final String? detailText;

  /// The error-detail dialog: the full diagnostics dump (mono, scrollable)
  /// with copy-to-clipboard — popped from the card's ghost info button.
  Future<void> _showErrorDetails(BuildContext context) =>
      showWatchErrorDetails(context, detailText!);

  @override
  Widget build(BuildContext context) {
    final errorColor = context.theme.colors.error;
    // The 16:9 canvas is ~232px tall in portrait (~297 landscape, ~180 on
    // small phones); after the top row and the dead scrubber the card has
    // ~140px or less. The mock's 40px icon circle cannot fit that budget —
    // the icon is dropped (triangleAlert rides the category badge's row),
    // and the whole card is scaleDown: any canvas shorter than the card
    // shrinks it uniformly instead of clipping the ACTION BUTTONS out of
    // reach behind the viewport's ClipRect.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FLucideIcons.triangleAlert, size: 14, color: errorColor),
                const SizedBox(width: 6),
                if (categoryLabel != null)
                  FBadge(
                    variant: .destructive,
                    style: .delta(
                      padding: EdgeInsetsGeometryDelta.value(
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                      labelTextStyle: TextStyleDelta.delta(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    child: Text(categoryLabel!),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'watch.playback_interrupted'.i18n,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'watch.could_not_reach_stream'.i18n,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withAlpha(153),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            // Wrap, not Row: with two labelled actions the pair can exceed a
            // narrow canvas (long locales) — the actions flow to a second
            // line instead of spilling.
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                // The user directive: the SMALLER button size (sm) —
                // the 40px md box dwarfed the compacted card.
                FButton(
                  variant: .primary,
                  size: .sm,
                  mainAxisSize: .min,
                  prefix: const Icon(FLucideIcons.rotateCcw, size: 14),
                  onPress: onRetry,
                  child: Text('watch.retry_connection'.i18n),
                ),
                if (mirrors.isNotEmpty)
                  MirrorPickerButton(
                    mirrors: mirrors,
                    onSelectMirror: onSelectMirror,
                  ),
              ],
            ),
            // The in-player diagnostics affordance: a small ghost info
            // button that pops the error-detail dialog (full dump + copy).
            if (detailText != null && detailText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              FButton(
                variant: .ghost,
                size: .xs,
                mainAxisSize: .min,
                prefix: const Icon(FLucideIcons.info, size: 14),
                onPress: () => unawaited(_showErrorDetails(context)),
                child: Text('watch.error_details'.i18n),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Switch Mirror": an outline button opening the failure's mirror list as
/// a popover menu. Shared by the viewport card and the diagnostics panel —
/// one picker, every call site renders through it.
class MirrorPickerButton extends HookWidget {
  const MirrorPickerButton({
    super.key,
    required this.mirrors,
    required this.onSelectMirror,
    this.dense = false,
  });

  final List<pb_extension.ExtensionMirror> mirrors;
  final ValueChanged<String>? onSelectMirror;

  /// The diagnostics row renders a compact ghost variant.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final controller = useFPopoverController();
    final errorColor = context.theme.colors.error;
    return FPopoverMenu.tiles(
      menu: [
        .group(
          children: [
            for (final mirror in mirrors)
              FTile(
                title: Text(
                  mirror.name.isEmpty ? mirror.url : mirror.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onPress: () {
                  controller.toggle();
                  onSelectMirror?.call(mirror.url);
                },
              ),
          ],
        ),
      ],
      maxHeight: 320,
      control: .managed(controller: controller),
      child: dense
          ? FButton(
              variant: .ghost,
              size: .xs,
              mainAxisSize: .min,
              onPress: controller.toggle,
              prefix: const Icon(FLucideIcons.gitBranch, size: 14),
              // Flexible: the diagnostics column bounds the button's width
              // (272 on a 320 phone) and the touch theme's larger xs text
              // must ellipsize instead of overflowing the content row.
              child: Flexible(
                child: Text(
                  'watch.select_fallback_mirror'.i18n,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          : FButton(
              variant: .outline,
              mainAxisSize: .min,
              style: .delta(
                contentStyle: .delta(
                  constraints: const BoxConstraints(minHeight: 40),
                ),
                iconContentStyle: .delta(
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
              onPress: controller.toggle,
              prefix: Icon(FLucideIcons.gitBranch, size: 15, color: errorColor),
              child: Text(
                'watch.switch_mirror'.i18n,
                style: TextStyle(
                  color: errorColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}
