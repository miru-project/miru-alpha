import 'package:widgetbook/widgetbook.dart';

import 'update_flow.dart';

/// The prototyping folder: knob-driven explorations, not assertions.
///
/// The mirrored folders answer "what does this component look like in each
/// state the tests pin". This one answers "what happens if…", which is the
/// question you have while a flow is still being designed. Nothing here is
/// covered by a widget test, so it must never be the only place a state exists.
WidgetbookFolder buildPrototypingFolder() {
  return WidgetbookFolder(
    name: 'Prototyping',
    children: [updateFlowComponent()],
  );
}
