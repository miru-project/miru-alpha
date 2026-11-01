import 'dart:async';

import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backend_connection_provider.g.dart';

/// Global backend gate.
///
/// The init page is gone: the app renders immediately and every backend
/// operation waits on [backendConnectionProvider.future] instead of a splash
/// screen. The build resolves only once [Core.ensureInitialized] succeeds
/// (gRPC `helloMiru` answered, settings loaded) and re-applies the user's
/// persisted theme/language, which until then run on the synchronous defaults
/// seeded at bootstrap.
///
/// While it pends, surfaces show their per-operation loading states and the
/// home/desktop title bars render the connecting status
/// ([BackendConnectionTitle]).
@Riverpod(keepAlive: true)
class BackendConnection extends _$BackendConnection {
  @override
  Future<void> build() async {
    while (true) {
      try {
        await Core.ensureInitialized();
        _applyPersistedAppearance();
        return;
      } catch (error, stack) {
        logger.severe('Backend connection failed, retrying', error, stack);
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  /// Re-derives theme and translations from the now-loaded settings cache:
  /// the bootstrap seeded synchronous defaults so the first frames resolve.
  void _applyPersistedAppearance() {
    try {
      ref.read(applicationControllerProvider.notifier).reloadFromSettings();
      final language = MiruSettings.getSettingSync<String>(SettingKey.language);
      unawaited(I18nUtils.changeLanguage(language));
    } catch (error, stack) {
      logger.severe('Failed to apply persisted appearance', error, stack);
    }
  }
}
