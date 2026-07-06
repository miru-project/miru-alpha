// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DownloadViewModel)
final downloadViewModelProvider = DownloadViewModelProvider._();

final class DownloadViewModelProvider
    extends $AsyncNotifierProvider<DownloadViewModel, List<DomainDownload>> {
  DownloadViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadViewModelHash();

  @$internal
  @override
  DownloadViewModel create() => DownloadViewModel();
}

String _$downloadViewModelHash() => r'be7c5bef6228e604379067af8fcfeab7bafbd3d2';

abstract class _$DownloadViewModel
    extends $AsyncNotifier<List<DomainDownload>> {
  FutureOr<List<DomainDownload>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<DomainDownload>>, List<DomainDownload>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<DomainDownload>>,
                List<DomainDownload>
              >,
              AsyncValue<List<DomainDownload>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
