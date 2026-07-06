// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_reader_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MangaReaderViewModel)
final mangaReaderViewModelProvider = MangaReaderViewModelFamily._();

final class MangaReaderViewModelProvider
    extends $NotifierProvider<MangaReaderViewModel, MangaReaderViewState> {
  MangaReaderViewModelProvider._({
    required MangaReaderViewModelFamily super.from,
    required ({
      int epIndex,
      int total,
      ExtensionMangaWatch? data,
      Map<String, String>? headers,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'mangaReaderViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mangaReaderViewModelHash();

  @override
  String toString() {
    return r'mangaReaderViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MangaReaderViewModel create() => MangaReaderViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MangaReaderViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MangaReaderViewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MangaReaderViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaReaderViewModelHash() =>
    r'a176c9f30cdf95e671d373e5c7f420197815e27b';

final class MangaReaderViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          MangaReaderViewModel,
          MangaReaderViewState,
          MangaReaderViewState,
          MangaReaderViewState,
          ({
            int epIndex,
            int total,
            ExtensionMangaWatch? data,
            Map<String, String>? headers,
          })
        > {
  MangaReaderViewModelFamily._()
    : super(
        retry: null,
        name: r'mangaReaderViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MangaReaderViewModelProvider call({
    int epIndex = 0,
    int total = 0,
    ExtensionMangaWatch? data,
    Map<String, String>? headers,
  }) => MangaReaderViewModelProvider._(
    argument: (epIndex: epIndex, total: total, data: data, headers: headers),
    from: this,
  );

  @override
  String toString() => r'mangaReaderViewModelProvider';
}

abstract class _$MangaReaderViewModel extends $Notifier<MangaReaderViewState> {
  late final _$args =
      ref.$arg
          as ({
            int epIndex,
            int total,
            ExtensionMangaWatch? data,
            Map<String, String>? headers,
          });
  int get epIndex => _$args.epIndex;
  int get total => _$args.total;
  ExtensionMangaWatch? get data => _$args.data;
  Map<String, String>? get headers => _$args.headers;

  MangaReaderViewState build({
    int epIndex = 0,
    int total = 0,
    ExtensionMangaWatch? data,
    Map<String, String>? headers,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MangaReaderViewState, MangaReaderViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MangaReaderViewState, MangaReaderViewState>,
              MangaReaderViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(
        epIndex: _$args.epIndex,
        total: _$args.total,
        data: _$args.data,
        headers: _$args.headers,
      ),
    );
  }
}
