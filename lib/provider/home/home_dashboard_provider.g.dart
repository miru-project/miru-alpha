// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeDashboard)
final homeDashboardProvider = HomeDashboardProvider._();

final class HomeDashboardProvider
    extends $NotifierProvider<HomeDashboard, HomeDashboardState> {
  HomeDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeDashboardHash();

  @$internal
  @override
  HomeDashboard create() => HomeDashboard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeDashboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeDashboardState>(value),
    );
  }
}

String _$homeDashboardHash() => r'bdf7c042c912aa5fdcd62e3b9a30eec41b5cc91c';

abstract class _$HomeDashboard extends $Notifier<HomeDashboardState> {
  HomeDashboardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeDashboardState, HomeDashboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeDashboardState, HomeDashboardState>,
              HomeDashboardState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
