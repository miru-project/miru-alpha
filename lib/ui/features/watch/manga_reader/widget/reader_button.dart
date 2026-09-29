import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

/// Control heights taken straight from the reference design.
///
/// FORUI's touch platform sizes buttons to a 44px minimum
/// (`contentConstraints: minWidth/minHeight 44`), which is correct Material
/// guidance but much taller than the reader HUD the reference specifies
/// (h-8 = 32px, h-9 = 36px). The HUD is a transient overlay whose primary
/// interaction — turning the page — is a full-screen tap zone, not these
/// buttons, so the reference geometry is applied deliberately.
abstract final class ReaderControlSize {
  /// Reference h-8: the bottom bar's Prev/Next/selector and shortcut buttons.
  static const double compact = 32;

  /// Reference h-9: the top bar's back/bookmark/chapters/settings buttons.
  static const double medium = 36;
}

/// [FButton] lays its content out in a NON-flexible [Row], so a long label
/// overflows instead of ellipsising. This wraps [FButton] with the public
/// `builder` hook that makes the label flexible.
///
/// Use it wherever the label is user data (chapter titles) or a localised
/// string that may be far longer than the English one.
class ReaderButton extends StatelessWidget {
  const ReaderButton({
    super.key,
    required this.onPress,
    required this.child,
    this.variant = .secondary,
    this.height,
    this.icon,
    this.suffix,
    this.onDisabledPress,
    this.mainAxisSize = .max,
    this.mainAxisAlignment = .center,
    this.square = false,
  });

  final VoidCallback? onPress;
  final VoidCallback? onDisabledPress;
  final Widget child;
  final FButtonVariant variant;

  /// Overrides the height. Use [ReaderControlSize] for the reference values;
  /// when null FORUI's own touch sizing is kept.
  final double? height;

  final Widget? icon;
  final Widget? suffix;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  /// Constrains the width to [height] as well, for icon-only actions.
  final bool square;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: variant,
      onPress: onPress,
      onDisabledPress: onDisabledPress,
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      prefix: icon,
      suffix: suffix,
      style: .delta(
        contentStyle: FButtonContentStyleDelta.delta(
          constraints: height == null
              ? null
              // minWidth/minHeight are the *content* box; FORUI centres the
              // content inside it, so driving the size from here (rather than
              // from derived padding) keeps the total height exactly [height]
              // whatever the label's font metrics turn out to be.
              : BoxConstraints(
                  minWidth: square ? height! : 0,
                  minHeight: height!,
                ),
          padding: height == null
              ? null
              : EdgeInsetsGeometryDelta.value(
                  // Horizontal padding only: a vertical value would fight
                  // minHeight and reintroduce the height drift.
                  EdgeInsets.symmetric(horizontal: square ? 0 : 10),
                ),
          // FORUI always inserts the content spacing between prefix/child/
          // suffix. An icon-only button has a zero-size child, so the default
          // 6px would silently widen it past [height].
          spacing: square ? 0 : null,
        ),
      ),
      builder: _flexChild,
      child: child,
    );
  }

  /// FButton's documented `builder` hook; wrapping the label in [Flexible] is
  /// what lets the internal Row shrink instead of overflowing.
  static Widget _flexChild(
    BuildContext context,
    FButtonStyle style,
    TextStyle textStyle,
    IconThemeData iconStyle,
    FCircularProgressStyle progressStyle,
    Widget? child,
  ) => Flexible(child: child ?? const SizedBox.shrink());
}

/// Single-line label that never overflows its slot.
///
/// [maxWidth] exists because `Flexible` alone is not enough: a label with no
/// break opportunity (a camel-cased i18n key, or a single-word language) has an
/// intrinsic width equal to its longest word, so the layout cannot shrink it
/// below that no matter how loose the constraint is.
class ReaderLabel extends StatelessWidget {
  const ReaderLabel(
    this.text, {
    super.key,
    this.softWrap,
    this.style,
    this.maxWidth,
  });

  /// Already-resolved text.
  final String text;

  /// Defaults to no wrapping; set true for labels that may break.
  final bool? softWrap;

  /// Overrides the inherited text style (size, weight, colour).
  final TextStyle? style;

  /// Caps the label's width so it ellipsises instead of overflowing.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      maxLines: 1,
      softWrap: softWrap ?? false,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    if (maxWidth == null) return label;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: label,
    );
  }
}
