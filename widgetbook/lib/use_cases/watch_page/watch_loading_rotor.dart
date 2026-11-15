/// Mirrors test/ui/features/watch/watch_loading_rotor_test.dart states for
/// the catalog.
///
/// The rotor is self-ticking: the 48px disc's arc rotates on a 3s cycle and
/// the shimmer sweeps on a 2s loop — visible live on the canvas.
///
/// Skipped states:
/// - skipped: 'rotor ticker stops when the viewport unmounts' — lifecycle
///   assertion (no pending timers after dispose), no distinct visual.

library;

import 'package:miru_alpha/ui/features/watch/widget/watch_loading_viewport.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// The mirrored-from-tests components of the loading rotor test.
List<WidgetbookComponent> buildLoadingRotorComponents() => [
  WidgetbookComponent(
    name: 'WatchLoadingViewport',
    useCases: [
      WidgetbookUseCase(
        name: 'Portrait 412x915 · resolver rotor',
        builder: (context) => PhoneFrame(
          child: WatchLoadingViewport(title: 'Daemons', onBack: () {}),
        ),
      ),
      WidgetbookUseCase(
        name: 'With extension identity · ExampleA',
        builder: (context) => PhoneFrame(
          child: WatchLoadingViewport(
            title: 'Daemons',
            onBack: () {},
            extensionName: 'ExampleA',
          ),
        ),
      ),
    ],
  ),
];
