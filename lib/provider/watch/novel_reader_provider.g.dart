// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_reader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NovelReader)
const novelReaderProvider = NovelReaderProvider._();

final class NovelReaderProvider
    extends $NotifierProvider<NovelReader, NovelReaderState> {
  const NovelReaderProvider._()
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

String _$novelReaderHash() => r'd82fe034497af504290b47cfdaaa82f0595d8d51';

abstract class _$NovelReader extends $Notifier<NovelReaderState> {
  NovelReaderState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NovelReaderState, NovelReaderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NovelReaderState, NovelReaderState>,
              NovelReaderState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
