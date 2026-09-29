// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

final class HomeViewModelProvider
    extends $NotifierProvider<HomeViewModel, HomeViewState> {
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  HomeViewModel create() => HomeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeViewState>(value),
    );
  }
}

String _$homeViewModelHash() => r'a8892c4427204e6bad54b36f9786a1dc5d2207df';

abstract class _$HomeViewModel extends $Notifier<HomeViewState> {
  HomeViewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeViewState, HomeViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeViewState, HomeViewState>,
              HomeViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedHomeTab)
final selectedHomeTabProvider = SelectedHomeTabProvider._();

final class SelectedHomeTabProvider
    extends $NotifierProvider<SelectedHomeTab, int> {
  SelectedHomeTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedHomeTabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedHomeTabHash();

  @$internal
  @override
  SelectedHomeTab create() => SelectedHomeTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$selectedHomeTabHash() => r'16854b9d77eb36c175dc52bfdf23902155832732';

abstract class _$SelectedHomeTab extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
