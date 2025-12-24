// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_reader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NovelReader)
const novelReaderProvider = NovelReaderFamily._();

final class NovelReaderProvider
    extends $NotifierProvider<NovelReader, NovelReaderState> {
  const NovelReaderProvider._({
    required NovelReaderFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'novelReaderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$novelReaderHash();

  @override
  String toString() {
    return r'novelReaderProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is NovelReaderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$novelReaderHash() => r'ae5f6ac06b488300754b1369e046cc170a290e31';

final class NovelReaderFamily extends $Family
    with
        $ClassFamilyOverride<
          NovelReader,
          NovelReaderState,
          NovelReaderState,
          NovelReaderState,
          List<String>
        > {
  const NovelReaderFamily._()
    : super(
        retry: null,
        name: r'novelReaderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NovelReaderProvider call(List<String> content) =>
      NovelReaderProvider._(argument: content, from: this);

  @override
  String toString() => r'novelReaderProvider';
}

abstract class _$NovelReader extends $Notifier<NovelReaderState> {
  late final _$args = ref.$arg as List<String>;
  List<String> get content => _$args;

  NovelReaderState build(List<String> content);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
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
