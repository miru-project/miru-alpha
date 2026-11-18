import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';

/// Compact <-> full expand/shrink timing and curve (`Curves.ease` — ease-in-out
/// rather than ease-out, so both ends of the size change are gentle). Growing
/// is the deliberate one; shrinking is quick so the card snaps back as soon as
/// the reader lets go.
const Duration _expandDuration = Duration(milliseconds: 220);
const Duration _shrinkDuration = Duration(milliseconds: 100);
const Curve _sizeCurve = Curves.ease;

/// Minimal progress pill shown when the reader HUD is hidden.
///
/// This is the mock's "Normal Viewing View": no buttons, just where the reader
/// is, plus a one-line hint that the centre tap brings the controls back.
class ReaderStatusPill extends StatelessWidget {
  const ReaderStatusPill({
    super.key,
    required this.chapterLabel,
    required this.page,
    required this.totalPage,
    required this.progress,
    this.borderRadius = 16.0,
    this.compact = false,
    this.showGrip = false,
  });

  final String chapterLabel;
  final int page;
  final int totalPage;
  final double progress;

  /// Visual corner radius. 16dp keeps the default pill shape; draggable
  /// anchor corners can request 0dp to render as a flush rectangle.
  final double borderRadius;

  /// Docked at a side: drops the chapter title and the percentage, leaving
  /// only `page / total`.
  final bool compact;

  /// Draws the drag knob on the card. Only true while the tap affordance is
  /// showing, so the resting pill is unchanged.
  final bool showGrip;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    // The pill is content-sized — a Center would expand without bound and the
    // surface would stretch edge-to-edge, which is why it is reported as
    // unbounded width at rest. IntrinsicWidth hands the card a tight fit.
    //
    // The radius the draggable morph produces is applied to the CONTENT card's
    // own shape (the outline badge), not to a wrapper around it: an outline
    // badge keeps its own pill radius unless its ShapeBorder is overridden, so
    // animating anything else leaves the card the reader actually looks at
    // unchanged. The frosted backdrop follows the same radius so a squared-off
    // card is not clipped by a rounded clip.
    // Compact <-> full is an animated width, not a swap: at a corner the card
    // is page/total only, and a press (or a drag) grows it to the full readout
    // and it shrinks back when the reader lets go. The ClipRect sits OUTSIDE
    // the AnimatedSize so the clip IS the animating box: mid-transition the
    // content is revealed along the curve, and once the box reaches the card's
    // width nothing is clipped and the real card shows.
    return ClipRect(
      child: AnimatedSize(
        // The duration is picked from the compact state, so a shrink runs at
        // _shrinkDuration and an expand at _expandDuration.
        duration: compact ? _shrinkDuration : _expandDuration,
        curve: _sizeCurve,
        alignment: Alignment.centerLeft,
        child: ReaderSurface(
          // Same frosted surface as the chrome: the pill floats over the
          // artwork while the reader scrolls, so it has to be readable against
          // a page.
          color: colors.background.withValues(alpha: kReaderPillAlpha),
          borderRadius: BorderRadius.circular(borderRadius),
          child: FBadge(
            variant: .outline,
            style: .delta(
              decoration: .shapeDelta(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  side: BorderSide(
                    color: colors.border,
                    width: context.theme.style.borderWidth,
                  ),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                if (!compact) ...[
                  Flexible(
                    child: Text(
                      chapterLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.xs.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  ),
                  const _PillDivider(),
                ],
                Text(
                  '$page / $totalPage',
                  style: context.theme.typography.body.xs.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!compact) ...[
                  const _PillDivider(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
                if (showGrip) const _PillGrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Key on the drag knob, so a widget test can assert the affordance is up.
const ValueKey<String> kReaderPillGripKey = ValueKey('reader-pill-grip');

/// The drag knob shown while the pill's tap affordance is up. Sits inside the
/// card with its own padding so it never touches the divider or the screen
/// edge, and uses [kReaderPillGripKey] so tests can find it.
class _PillGrip extends StatelessWidget {
  const _PillGrip();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: SizedBox(
        key: kReaderPillGripKey,
        width: 14,
        height: 18,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bar(colors.mutedForeground),
              const SizedBox(height: 3),
              _bar(colors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(Color color) => Container(
    width: 10,
    height: 2,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(1),
    ),
  );
}

class _PillDivider extends StatelessWidget {
  const _PillDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: context.theme.colors.border,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
