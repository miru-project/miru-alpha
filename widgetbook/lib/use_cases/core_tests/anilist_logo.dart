import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/widget/app_svgs.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/core/anilist_logo_test.dart states for the catalog.
///
/// The test's string assertion (the inlined `kAniListSvg` carries the logo
/// path) is non-visual — proven by rendering the logo at all. The widget
/// test pumps `anilistLogo(size: 13, color: Colors.white)`; the white mark
/// sits on a fixed dark swatch so it stays visible on any catalog theme.
WidgetbookComponent buildAnilistLogoComponent() {
  return WidgetbookComponent(
    name: 'AniList logo',
    useCases: [
      WidgetbookUseCase(
        name: 'Renders at 13px (white)',
        builder: (context) {
          final size = context.knobs.double.slider(
            label: 'Size',
            initialValue: 13,
            min: 8,
            max: 64,
          );
          return catalogFrame(
            Padding(
              padding: const EdgeInsets.all(24),
              child: ColoredBox(
                color: const Color(0xFF27272A),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: anilistLogo(size: size, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}
