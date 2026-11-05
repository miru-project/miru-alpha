// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_reader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one novel reader state.
///
/// A reader is a single full-screen surface, so the state is a single
/// auto-dispose provider — not a family keyed on the chapter text. Family
/// arguments are hashed into provider identity, so keying on the content
/// minted a fresh element (and pinned the whole chapter) per fetch. The
/// chapter text flows to the canvas through the shell's widget parameters
/// instead; [open] injects a fresh session on entry, and leaving the reader
/// disposes the element back to nothing.

@ProviderFor(NovelReader)
final novelReaderProvider = NovelReaderProvider._();

/// The one novel reader state.
///
/// A reader is a single full-screen surface, so the state is a single
/// auto-dispose provider — not a family keyed on the chapter text. Family
/// arguments are hashed into provider identity, so keying on the content
/// minted a fresh element (and pinned the whole chapter) per fetch. The
/// chapter text flows to the canvas through the shell's widget parameters
/// instead; [open] injects a fresh session on entry, and leaving the reader
/// disposes the element back to nothing.
final class NovelReaderProvider
    extends $NotifierProvider<NovelReader, NovelReaderState> {
  /// The one novel reader state.
  ///
  /// A reader is a single full-screen surface, so the state is a single
  /// auto-dispose provider — not a family keyed on the chapter text. Family
  /// arguments are hashed into provider identity, so keying on the content
  /// minted a fresh element (and pinned the whole chapter) per fetch. The
  /// chapter text flows to the canvas through the shell's widget parameters
  /// instead; [open] injects a fresh session on entry, and leaving the reader
  /// disposes the element back to nothing.
  NovelReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'novelReaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$novelReaderHash();

  @$internal
  @override
  NovelReader create() => NovelReader();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NovelReaderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NovelReaderState>(value),
    );
  }
}

String _$novelReaderHash() => r'6a7039abe31a856751b4a1cd958d92a9a7783d54';

/// The one novel reader state.
///
/// A reader is a single full-screen surface, so the state is a single
/// auto-dispose provider — not a family keyed on the chapter text. Family
/// arguments are hashed into provider identity, so keying on the content
/// minted a fresh element (and pinned the whole chapter) per fetch. The
/// chapter text flows to the canvas through the shell's widget parameters
/// instead; [open] injects a fresh session on entry, and leaving the reader
/// disposes the element back to nothing.

abstract class _$NovelReader extends $Notifier<NovelReaderState> {
  NovelReaderState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NovelReaderState, NovelReaderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NovelReaderState, NovelReaderState>,
              NovelReaderState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
