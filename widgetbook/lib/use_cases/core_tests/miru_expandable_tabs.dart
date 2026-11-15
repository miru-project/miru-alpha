import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/core/miru_expandable_tabs.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/core/miru_expandable_tabs_widget_test.dart states for the
/// catalog.
///
/// The tap-callback check (`onIndexChanged` fires with the tapped index) is
/// behavior-only — the interactive use-case is its one representative
/// surface. The 400px host mirrors the test's fixed-width column.
WidgetbookComponent buildMiruExpandableTabsComponent() {
  return WidgetbookComponent(
    name: 'MiruExpandableTabs',
    useCases: [
      WidgetbookUseCase(
        name: 'First pill active (default)',
        builder: (context) =>
            catalogFrame(const SizedBox(width: 400, child: _TabsDemo())),
      ),
      WidgetbookUseCase(
        name: 'Second pill active (controlled)',
        builder: (context) => catalogFrame(
          const SizedBox(width: 400, child: _TabsDemo(initialIndex: 1)),
        ),
      ),
      WidgetbookUseCase(
        name: 'Interactive (tap to switch)',
        builder: (context) => catalogFrame(
          const SizedBox(width: 400, child: _TabsDemo(interactive: true)),
        ),
      ),
    ],
  );
}

/// The test's three-tab fixture: heart / book / gift pills.
class _TabsDemo extends StatefulWidget {
  const _TabsDemo({this.initialIndex = 0, this.interactive = false});

  final int initialIndex;
  final bool interactive;

  @override
  State<_TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<_TabsDemo> {
  int? _tapped;

  int get _index => _tapped ?? widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return MiruExpandableTabs(
      selectedIndex: _index,
      onIndexChanged: widget.interactive
          ? (i) => setState(() => _tapped = i)
          : null,
      children: [
        MiruExpandableTabEntry(
          icon: const Icon(FLucideIcons.heart),
          label: const Text('Tab One'),
        ),
        MiruExpandableTabEntry(
          icon: const Icon(FLucideIcons.book),
          label: const Text('Tab Two'),
        ),
        MiruExpandableTabEntry(
          icon: const Icon(FLucideIcons.gift),
          label: const Text('Tab Three'),
        ),
      ],
    );
  }
}
