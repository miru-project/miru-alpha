import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

/// Frame every catalog use-case renders inside.
///
/// Mirrors the app's own shell pieces a use-case may exercise: FToaster hosts
/// showFToast (mirrors app_bootstrap's builder wrap), the padding keeps dense
/// components off the viewport edge, and centering frames leaf components the
/// way the AlignmentAddon would without double-wrapping full-screen layouts.
/// The FTheme comes from the catalog's ThemeAddon, not from here — use-cases
/// always render the theme currently selected in the catalog UI.
Widget catalogFrame(Widget child, {bool center = true, bool padded = true}) {
  Widget result = child;
  if (padded) {
    result = Padding(padding: const EdgeInsets.all(16), child: result);
  }
  if (center) result = Center(child: result);
  return FToaster(child: result);
}

/// A phone-sized canvas (the debug preview's 412x915) for use-cases mirroring
/// mobile layouts — the components are width-breakpoint driven, so the viewport
/// addon can also be used; this frame guarantees the shape when a screenshot
/// or a wide monitor would otherwise stretch the layout.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 412,
        height: 915,
        child: ColoredBox(
          color: context.theme.colors.background,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}
