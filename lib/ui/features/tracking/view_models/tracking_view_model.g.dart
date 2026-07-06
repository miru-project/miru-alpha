// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrackingViewModel)
final trackingViewModelProvider = TrackingViewModelProvider._();

final class TrackingViewModelProvider
    extends $AsyncNotifierProvider<TrackingViewModel, TrackingViewState> {
  TrackingViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingViewModelHash();

  @$internal
  @override
  TrackingViewModel create() => TrackingViewModel();
}

String _$trackingViewModelHash() => r'f2da6bf65f2d3f26be34204a97a3432a7ac746c3';

abstract class _$TrackingViewModel extends $AsyncNotifier<TrackingViewState> {
  FutureOr<TrackingViewState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TrackingViewState>, TrackingViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrackingViewState>, TrackingViewState>,
              AsyncValue<TrackingViewState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
