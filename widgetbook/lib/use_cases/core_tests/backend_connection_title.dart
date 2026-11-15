import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/ui/core/connection/backend_connection_title.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/core/connection/backend_connection_title_test.dart states
/// for the catalog.
///
/// Same fakes as the test: a never-resolving connection holds the connecting
/// state, a plain-resolving one flips to online. i18n renders the raw key
/// (`common.connecting`) and the status line shows Core's defaults
/// (`127.0.0.1:3000`) — the bare-harness regime.
class _PendingConnection extends BackendConnection {
  @override
  Future<void> build() => Completer<void>().future;
}

class _OnlineConnection extends BackendConnection {
  @override
  Future<void> build() async {}
}

Widget _host(BackendConnection Function() factory) {
  return ProviderScope(
    overrides: [backendConnectionProvider.overrideWith(factory)],
    child: SizedBox(
      width: 320,
      child: BackendConnectionTitle(title: const Text('TITLE')),
    ),
  );
}

WidgetbookComponent buildBackendConnectionTitleComponent() {
  return WidgetbookComponent(
    name: 'BackendConnectionTitle',
    useCases: [
      WidgetbookUseCase(
        name: 'Connecting · status column, title parked below',
        builder: (context) => catalogFrame(_host(_PendingConnection.new)),
      ),
      WidgetbookUseCase(
        name: 'Online · title risen, status slid out',
        builder: (context) => catalogFrame(_host(_OnlineConnection.new)),
      ),
    ],
  );
}
