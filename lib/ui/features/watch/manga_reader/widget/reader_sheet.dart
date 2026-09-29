import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Opaque rounded-top panel shared by the reader's two modal sheets.
///
/// FORUI's `showFSheet` draws only a barrier (the app theme's 48% scrim) and
/// no surface of its own, so without this the manga page reads straight through
/// the sheet content. The reference draws an opaque `rounded-t-xl` panel with a
/// hairline along its top edge, which is what this reproduces.
class ReaderSheetPanel extends StatelessWidget {
  const ReaderSheetPanel({
    super.key,
    required this.child,
    this.maxHeightFactor,
  });

  final Widget child;

  /// Optional cap as a fraction of the screen height. Sheets that size
  /// themselves from their content do not need one.
  final double? maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(color: colors.border),
          left: BorderSide(color: colors.border),
          right: BorderSide(color: colors.border),
        ),
      ),
      child: maxHeightFactor == null
          ? child
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor!,
              ),
              child: child,
            ),
    );
  }
}

/// The grab pill at the top of a bottom sheet, which doubles as the reference's
/// close affordance.
class ReaderSheetHandle extends StatelessWidget {
  const ReaderSheetHandle({super.key, this.onPress});

  /// Tapped to dismiss the sheet. Optional: a purely decorative handle is fine
  /// when the sheet also has a close button.
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.theme.colors.border,
        borderRadius: .circular(2),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: onPress == null
            ? pill
            : FTappable(
                onPress: onPress!,
                semanticsLabel: 'common.close'.i18n,
                child: pill,
              ),
      ),
    );
  }
}
