// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingsViewModel)
final settingsViewModelProvider = SettingsViewModelProvider._();

final class SettingsViewModelProvider
    extends $AsyncNotifierProvider<SettingsViewModel, DomainAppSettings> {
  SettingsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsViewModelHash();

  @$internal
  @override
  SettingsViewModel create() => SettingsViewModel();
}

String _$settingsViewModelHash() => r'4558398f6f2ba37817507bddb224c71152c3fa41';

abstract class _$SettingsViewModel extends $AsyncNotifier<DomainAppSettings> {
  FutureOr<DomainAppSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DomainAppSettings>, DomainAppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DomainAppSettings>, DomainAppSettings>,
              AsyncValue<DomainAppSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
