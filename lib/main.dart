import 'package:flutter/widgets.dart';

import 'app_bootstrap.dart';

/// Release entry point.
///
/// Deliberately free of marionette imports: the debug harness lives in
/// [main_debug.dart] and is the only entry that pulls
/// `marionette_flutter` / `marionette_logging` into the compile graph, so
/// release builds never read or compile that source (the injected
/// [runMiruApp] binding hook is what makes the split possible — a
/// `if (kDebugMode)` conditional import does not: only `dart.library.*`
/// conditions are honoured, so the previous self-referencing conditional
/// still imported the packages into release builds).
void main() {
  runMiruApp(ensureBinding: WidgetsFlutterBinding.ensureInitialized);
}
