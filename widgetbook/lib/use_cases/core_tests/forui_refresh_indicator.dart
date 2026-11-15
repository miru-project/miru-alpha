import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/refresh/forui_header.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/core/forui_refresh_indicator_test.dart states for the
/// catalog.
///
/// The test pins the layout to staying healthy when EasyRefresh hands the
/// Forui indicator a horizontal axis (a horizontal list's ballistic flip used
/// to trip the infinite-size assertion). Both states here are live: drag the
/// list past its edge to fire the ForuiHeader indicator exactly as the drag
/// in the test does.
WidgetbookComponent buildForuiRefreshIndicatorComponent() {
  return WidgetbookComponent(
    name: 'ForuiHeader (EasyRefresh host)',
    useCases: [
      WidgetbookUseCase(
        name: 'Horizontal list — drag right edge to refresh',
        builder: (context) => catalogFrame(
          _host(
            ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 20,
              itemBuilder: (context, index) =>
                  SizedBox(width: 120, child: Text('item $index')),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Vertical list — drag top edge to refresh',
        builder: (context) => catalogFrame(
          _host(
            ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  SizedBox(height: 60, child: Text('item $index')),
            ),
          ),
        ),
      ),
    ],
  );
}

/// EasyRefresh needs bounded constraints; the phone canvas gives the list
/// the same full-surface shape the test's Scaffold body did.
Widget _host(Widget list) {
  return PhoneFrame(
    child: EasyRefresh(
      header: const ForuiHeader(),
      onRefresh: () async {},
      child: list,
    ),
  );
}
