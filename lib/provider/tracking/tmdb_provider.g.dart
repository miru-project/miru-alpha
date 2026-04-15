// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TMDBNotifier)
final tMDBProvider = TMDBNotifierProvider._();

final class TMDBNotifierProvider
    extends $AsyncNotifierProvider<TMDBNotifier, TMDBDetail?> {
  TMDBNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tMDBProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tMDBNotifierHash();

  @$internal
  @override
  TMDBNotifier create() => TMDBNotifier();
}

String _$tMDBNotifierHash() => r'3a71a75ac64fc24a1949a03647c6cb9e9195d596';

abstract class _$TMDBNotifier extends $AsyncNotifier<TMDBDetail?> {
  FutureOr<TMDBDetail?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TMDBDetail?>, TMDBDetail?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TMDBDetail?>, TMDBDetail?>,
              AsyncValue<TMDBDetail?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
