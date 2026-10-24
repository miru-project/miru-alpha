// Debug-only entry point: launches the app under the marionette binding so
// the marionette CLI can drive it (elements, taps, logs). NEVER reference
// this file from release code — it is the single place that imports
// `marionette_flutter` / `marionette_logging`, keeping both packages out of
// the release compile graph (see lib/main.dart).
// ignore: depend_on_referenced_packages
import 'package:marionette_flutter/marionette_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:marionette_logging/marionette_logging.dart';

import 'app_bootstrap.dart';

void main() {
  runMiruApp(
    ensureBinding: () => MarionetteBinding.ensureInitialized(
      MarionetteConfiguration(logCollector: LoggingLogCollector()),
    ),
  );
}
