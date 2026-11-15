/// Mirrors test/ui/features/extension/extension_store_header_test.dart
/// states for the catalog.
///
/// skipped: the pinned-header scroll geometry and the 44dp touch-target
/// measurements — pixel assertions the catalog shows live (scroll the list
/// in the default use-case; the header pills are the 44dp targets) rather
/// than as separate states.
///
/// The status sheet is internal state — tap the status pill in the catalog
/// to open it, exactly like the test taps its pill. The NSFW-filtered seed
/// (30 seeded − 2 installed − 1 nsfw-hidden = 27 available) and the
/// pkg2 update fixture come from the test's `_seedState`. i18n keys render
/// raw here (no delegates — expected); the view reads the NSFW setting at
/// build, so builders seed the shipped defaults.
library;

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/domain/models/extension_view.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/features/extension/view_models/extension_view_model.dart';
import 'package:miru_alpha/ui/features/extension/views/extension_list_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// The store's use-cases, merged into one 'ExtensionListView' component by
/// the area index (the i18n canary file tests the same widget).
List<WidgetbookUseCase> extensionStoreHeaderUseCases() {
  return [
    WidgetbookUseCase(
      name: 'Store — default (opens on Available, 27 tiles)',
      builder: _defaultStore,
    ),
    WidgetbookUseCase(
      name: 'Status sheet — tap the status pill',
      builder: _statusSheet,
    ),
  ];
}

DomainExtensionMeta _meta(
  String pkg,
  String name,
  ExtensionType type, {
  String version = '1.0.0',
  bool nsfw = false,
}) => DomainExtensionMeta(
  name: name,
  packageName: pkg,
  version: version,
  author: 't',
  lang: 'en',
  type: type,
  nsfw: nsfw,
);

/// The view model with the Go backend cut out and the state seeded, so the
/// page renders offline.
class _FakeExtensionViewModel extends ExtensionViewModel {
  _FakeExtensionViewModel(this._seed);

  final DomainExtensionViewState _seed;

  @override
  DomainExtensionViewState build() => _seed;

  @override
  Future<void> loadRepos({bool force = false}) async {
    // No backend in the catalog; the seeded repo is already the whole world.
  }
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);

  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

/// Enough extensions to scroll: 30 tiles of ~76px against a 900px viewport.
DomainExtensionViewState _seedState() {
  final extensions = [
    for (var i = 0; i < 30; i++)
      _meta(
        'pkg$i',
        'Ext$i',
        i.isEven ? ExtensionType.bangumi : ExtensionType.manga,
        nsfw: i == 29,
      ),
  ];
  return DomainExtensionViewState(
    repos: [
      DomainExtensionRepo(
        name: 'Miru Project',
        url: 'https://raw.example.com/index.json',
        extensions: extensions,
      ),
    ],
    // Two installed, one of them behind the repo version (an update).
    installedPackages: const ['pkg2', 'pkg4'],
    metadata: [
      _meta('pkg2', 'Ext2', ExtensionType.bangumi, version: '0.9.0'),
      _meta('pkg4', 'Ext4', ExtensionType.bangumi, version: '1.0.0'),
    ],
  );
}

Widget _store(BuildContext context) {
  MiruSettings.seedDefaults();
  final theme = ThemeUtils.getThemeData(MiruThemes.zinc.light);
  final container = ProviderContainer(
    overrides: [
      extensionViewModelProvider.overrideWith(
        () => _FakeExtensionViewModel(_seedState()),
      ),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(
          ApplicationState(
            themeText: 'light',
            baseColor: 'zinc',
            primaryColor: 'zinc',
            themeData: theme,
            themeMode: ThemeMode.light,
            language: 'en',
          ),
        ),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: PhoneFrame(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const ExtensionListView(),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _defaultStore(BuildContext context) => _store(context);

Widget _statusSheet(BuildContext context) => _store(context);

/// The seeded store fixture, shared with the i18n canary file's use-case.
Widget buildSeededStore(BuildContext context) => _store(context);
