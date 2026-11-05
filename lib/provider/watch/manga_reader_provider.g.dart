// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_reader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one manga reader state.
///
/// A reader is a single full-screen surface, so the state is a single
/// auto-dispose provider — not a family minting an element per episode. An
/// episode switch is [MangaReader.open]; leaving the reader disposes the
/// element and everything it holds.
///
/// The family it replaces took the watch response as an argument. Family
/// arguments are hashed into the provider identity and stringified on every
/// state change by the debug tooling, so a fresh protobuf object per fetch
/// minted a new element each rebuild and pinned the whole page URL list on
/// every retained identity until the heap gave out.
///
/// The page URLs are not state either: the viewport reads them from the watch
/// data it already holds, and the live scroll position streams to the canvas
/// through [ScrollOffsetListener] instead of Riverpod state.

@ProviderFor(MangaReader)
final mangaReaderProvider = MangaReaderProvider._();

/// The one manga reader state.
///
/// A reader is a single full-screen surface, so the state is a single
/// auto-dispose provider — not a family minting an element per episode. An
/// episode switch is [MangaReader.open]; leaving the reader disposes the
/// element and everything it holds.
///
/// The family it replaces took the watch response as an argument. Family
/// arguments are hashed into the provider identity and stringified on every
/// state change by the debug tooling, so a fresh protobuf object per fetch
/// minted a new element each rebuild and pinned the whole page URL list on
/// every retained identity until the heap gave out.
///
/// The page URLs are not state either: the viewport reads them from the watch
/// data it already holds, and the live scroll position streams to the canvas
/// through [ScrollOffsetListener] instead of Riverpod state.
final class MangaReaderProvider
    extends $NotifierProvider<MangaReader, MangaReaderState> {
  /// The one manga reader state.
  ///
  /// A reader is a single full-screen surface, so the state is a single
  /// auto-dispose provider — not a family minting an element per episode. An
  /// episode switch is [MangaReader.open]; leaving the reader disposes the
  /// element and everything it holds.
  ///
  /// The family it replaces took the watch response as an argument. Family
  /// arguments are hashed into the provider identity and stringified on every
  /// state change by the debug tooling, so a fresh protobuf object per fetch
  /// minted a new element each rebuild and pinned the whole page URL list on
  /// every retained identity until the heap gave out.
  ///
  /// The page URLs are not state either: the viewport reads them from the watch
  /// data it already holds, and the live scroll position streams to the canvas
  /// through [ScrollOffsetListener] instead of Riverpod state.
  MangaReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mangaReaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mangaReaderHash();

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
}

String _$mangaReaderHash() => r'a661f99ba9bab65cff17132a6191b65b41bf6c50';

/// The one manga reader state.
///
/// A reader is a single full-screen surface, so the state is a single
/// auto-dispose provider — not a family minting an element per episode. An
/// episode switch is [MangaReader.open]; leaving the reader disposes the
/// element and everything it holds.
///
/// The family it replaces took the watch response as an argument. Family
/// arguments are hashed into the provider identity and stringified on every
/// state change by the debug tooling, so a fresh protobuf object per fetch
/// minted a new element each rebuild and pinned the whole page URL list on
/// every retained identity until the heap gave out.
///
/// The page URLs are not state either: the viewport reads them from the watch
/// data it already holds, and the live scroll position streams to the canvas
/// through [ScrollOffsetListener] instead of Riverpod state.

abstract class _$MangaReader extends $Notifier<MangaReaderState> {
  MangaReaderState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MangaReaderState, MangaReaderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MangaReaderState, MangaReaderState>,
              MangaReaderState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
