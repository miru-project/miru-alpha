import 'package:widgetbook/widgetbook.dart';

import 'mobile_landscape_controls.dart';
import 'player_seek_burst.dart';
import 'seek_bar_scrub.dart';
import 'watch_error_layout_matrix.dart';
import 'watch_loading_error_states.dart';
import 'watch_loading_rotor.dart';
import 'watch_mobile_page.dart';

/// The 'Watch (mirrored)' folder: every widget-test state of
/// test/ui/features/watch/, mirrored as catalog use-cases (fakes only).
///
/// Components under test by more than one assigned test file
/// ([WatchHeaderSection], [MobileDetailTile], [MobileGestureOverlay]) are
/// merged here: one component per widget, its use-cases concatenated in
/// test-file order.
WidgetbookFolder buildWatchMirroredFolder() => WidgetbookFolder(
  name: 'Watch (mirrored)',
  children: _mergeByName([
    ...buildMobilePageComponents(),
    ...buildLoadingErrorStateComponents(),
    ...buildErrorLayoutMatrixComponents(),
    ...buildLoadingRotorComponents(),
    ...buildPlayerSeekBurstComponents(),
    ...buildSeekBarScrubComponents(),
    ...buildMobileLandscapeControlsComponents(),
  ]),
);

/// Groups the area files' components by name, concatenating use-cases.
List<WidgetbookComponent> _mergeByName(List<WidgetbookComponent> all) {
  final useCases = <String, List<WidgetbookUseCase>>{};
  final order = <String>[];
  for (final component in all) {
    final bucket = useCases.putIfAbsent(component.name, () {
      order.add(component.name);
      return [];
    });
    bucket.addAll(component.useCases);
  }
  return [
    for (final name in order)
      WidgetbookComponent(name: name, useCases: useCases[name]!),
  ];
}
