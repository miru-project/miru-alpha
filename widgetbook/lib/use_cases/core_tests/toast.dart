import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/core/toast_test.dart states for the catalog.
///
/// Both harnesses pump a MaterialApp around the router's root navigator key
/// — the exact context the toast helpers read. Without an FToaster above
/// that navigator the toast is dropped with a logged `logger.warning` (the
/// catalog does not surface logs — the dropped states simply render nothing
/// after firing).
Widget _toastApp({
  required bool toaster,
  required String buttonLabel,
  required VoidCallback onFire,
}) {
  return MaterialApp(
    navigatorKey: RouterUtil.rootNavigatorKey,
    builder: (context, child) => toaster ? FToaster(child: child!) : child!,
    home: Scaffold(
      body: Center(
        child: FButton(onPress: onFire, child: Text(buttonLabel)),
      ),
    ),
  );
}

WidgetbookComponent buildToastComponent() {
  return WidgetbookComponent(
    name: 'Toast helpers',
    useCases: [
      WidgetbookUseCase(
        name: 'Simple toast · FToaster mounted',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 480,
            height: 300,
            child: _toastApp(
              toaster: true,
              buttonLabel: 'showSimpleToast("Saved")',
              onFire: () => showSimpleToast('Saved'),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Simple toast · dropped without FToaster',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 480,
            height: 300,
            child: _toastApp(
              toaster: false,
              buttonLabel: 'showSimpleToast("Saved") — no FToaster',
              onFire: () => showSimpleToast('Saved'),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Icon toast · dropped without FToaster',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 480,
            height: 300,
            child: _toastApp(
              toaster: false,
              buttonLabel: 'iconsMessageToast("Downloading") — no FToaster',
              onFire: () =>
                  iconsMessageToast(title: 'Downloading', icon: Icons.download),
            ),
          ),
        ),
      ),
    ],
  );
}
