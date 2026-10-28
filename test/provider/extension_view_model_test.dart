import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/ui/features/extension/view_models/extension_view_model.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

void main() {
  group('ExtensionViewModel.applyMetadataSnapshot', () {
    late ProviderContainer container;

    setUp(() {
      MiruSettings.seedDefaultsForTest();
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('the installed set comes from the snapshot packages', () {
      final notifier = container.read(extensionViewModelProvider.notifier);
      expect(notifier.state.installedPackages, isEmpty);

      notifier.applyMetadataSnapshot([
        proto.ExtensionMeta(package: 'exampleb.si', version: 'v1.0.0'),
        proto.ExtensionMeta(package: 'exampleC.net', version: 'v0.1.0'),
      ]);

      expect(
        container.read(extensionViewModelProvider).installedPackages,
        unorderedEquals(['exampleb.si', 'exampleC.net']),
      );
      expect(notifier.isInstalled('exampleb.si'), isTrue);
      expect(notifier.isInstalled('missing.pkg'), isFalse);
    });

    test('an empty snapshot clears the installed set', () {
      final notifier = container.read(extensionViewModelProvider.notifier);
      notifier.applyMetadataSnapshot([
        proto.ExtensionMeta(package: 'exampleb.si'),
      ]);

      // The backend publishes the whole list, so an empty one means the folder
      // lost every extension (uninstalled from outside the app).
      notifier.applyMetadataSnapshot([]);

      expect(
        container.read(extensionViewModelProvider).installedPackages,
        isEmpty,
      );
      expect(notifier.isInstalled('exampleb.si'), isFalse);
    });

    test('maps the snapshot into domain metadata', () {
      final notifier = container.read(extensionViewModelProvider.notifier);
      notifier.applyMetadataSnapshot([
        proto.ExtensionMeta(
          name: 'ExampleC',
          package: 'exampleC.net',
          version: 'v0.1.0',
          type: 'manga',
          nsfw: true,
          error: 'compile failed',
        ),
      ]);

      final meta = container.read(extensionViewModelProvider).metadata.single;
      expect(meta.name, 'ExampleC');
      expect(meta.packageName, 'exampleC.net');
      expect(meta.type, ExtensionType.manga);
      expect(meta.nsfw, isTrue);
      expect(meta.error, 'compile failed');
    });

    test('an unknown media type falls back to all', () {
      final notifier = container.read(extensionViewModelProvider.notifier);
      notifier.applyMetadataSnapshot([
        proto.ExtensionMeta(package: 'weird.ext', type: 'unknown'),
      ]);

      expect(
        container.read(extensionViewModelProvider).metadata.single.type,
        ExtensionType.all,
      );
    });
  });
}
