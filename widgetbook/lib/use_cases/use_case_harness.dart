import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';

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

/// A phone-sized canvas that *is* a phone as far as Flutter and forui are
/// concerned.
///
/// Sizing the box is not enough, and that is the trap this frame exists to
/// close: forui reads touch typography and control sizes from the
/// [FThemeData] (`touch: true`), and anything responsive reads [MediaQuery] —
/// `FDialog.adaptive` picks its vertical layout below `breakpoints.sm` (640),
/// and the app's own width checks do the same. A 412-wide box inside the
/// catalog's 1900-wide window therefore rendered *desktop* tokens and took
/// *desktop* branches: a story labelled mobile was a desktop story in a small
/// box.
///
/// So the frame supplies all three things a phone has:
///
/// * a phone-sized [MediaQuery], so width-driven code sees 412, not the window;
/// * the touch twin of the ambient theme, paired by brightness exactly the way
///   `ThemeUtils.getThemeData` pairs them in the app at startup;
/// * its own [Navigator], so a dialog opened from a mobile story covers the
///   phone's screen instead of floating over the whole catalog.
///
/// A catalog theme with no touch twin in [MiruThemes] would silently fall back
/// to desktop tokens here — add the pair to `MiruThemes` when adding a theme.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({
    super.key,
    required this.child,
    this.width = 412,
    this.height = 915,
  });

  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final platform =
        context.theme.colors.brightness == Brightness.dark
            ? MiruThemes.zinc.dark
            : MiruThemes.zinc.light;
    final touch = platform.touch;

    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: FTheme(
          data: touch,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(width, height),
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.zero,
            ),
            child: ColoredBox(
              color: touch.colors.background,
              child: ClipRect(
                child: Navigator(
                  onGenerateRoute: (settings) => MaterialPageRoute<void>(
                    builder: (_) => child,
                    settings: settings,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}