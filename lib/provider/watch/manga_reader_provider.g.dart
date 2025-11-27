// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_reader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MangaReader)
const mangaReaderProvider = MangaReaderFamily._();

final class MangaReaderProvider
    extends $NotifierProvider<MangaReader, MangaReaderState> {
  const MangaReaderProvider._({
    required MangaReaderFamily super.from,
    required (int, int, ExtensionMangaWatch, {Map<String, String>? headers})
    super.argument,
  }) : super(
         retry: null,
         name: r'mangaReaderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mangaReaderHash();

  @override
  String toString() {
    return r'mangaReaderProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MangaReader create() => MangaReader();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MangaReaderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MangaReaderState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MangaReaderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaReaderHash() => r'7dc3568af04d05c3fc9f56699763f92438db6bb0';

final class MangaReaderFamily extends $Family
    with
        $ClassFamilyOverride<
          MangaReader,
          MangaReaderState,
          MangaReaderState,
          MangaReaderState,
          (int, int, ExtensionMangaWatch, {Map<String, String>? headers})
        > {
  const MangaReaderFamily._()
    : super(
        retry: null,
        name: r'mangaReaderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MangaReaderProvider call(
    int epIndex,
    int total,
    ExtensionMangaWatch data, {
    Map<String, String>? headers,
  }) => MangaReaderProvider._(
    argument: (epIndex, total, data, headers: headers),
    from: this,
  );

  @override
  String toString() => r'mangaReaderProvider';
}

abstract class _$MangaReader extends $Notifier<MangaReaderState> {
  late final _$args =
      ref.$arg
          as (int, int, ExtensionMangaWatch, {Map<String, String>? headers});
  int get epIndex => _$args.$1;
  int get total => _$args.$2;
  ExtensionMangaWatch get data => _$args.$3;
  Map<String, String>? get headers => _$args.headers;

  MangaReaderState build(
    int epIndex,
    int total,
    ExtensionMangaWatch data, {
    Map<String, String>? headers,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args.$1,
      _$args.$2,
      _$args.$3,
      headers: _$args.headers,
    );
    final ref = this.ref as $Ref<MangaReaderState, MangaReaderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MangaReaderState, MangaReaderState>,
              MangaReaderState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
