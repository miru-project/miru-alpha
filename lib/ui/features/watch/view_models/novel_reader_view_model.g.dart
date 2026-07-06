// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_reader_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NovelReaderViewModel)
final novelReaderViewModelProvider = NovelReaderViewModelFamily._();

final class NovelReaderViewModelProvider
    extends $NotifierProvider<NovelReaderViewModel, NovelReaderViewState> {
  NovelReaderViewModelProvider._({
    required NovelReaderViewModelFamily super.from,
    required ({List<String>? content, String? localPath}) super.argument,
  }) : super(
         retry: null,
         name: r'novelReaderViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$novelReaderViewModelHash();

  @override
  String toString() {
    return r'novelReaderViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  NovelReaderViewModel create() => NovelReaderViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NovelReaderViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NovelReaderViewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NovelReaderViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$novelReaderViewModelHash() =>
    r'ceaca4398d357c40b996e8e769195c95510a8e57';

final class NovelReaderViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          NovelReaderViewModel,
          NovelReaderViewState,
          NovelReaderViewState,
          NovelReaderViewState,
          ({List<String>? content, String? localPath})
        > {
  NovelReaderViewModelFamily._()
    : super(
        retry: null,
        name: r'novelReaderViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NovelReaderViewModelProvider call({
    required List<String>? content,
    required String? localPath,
  }) => NovelReaderViewModelProvider._(
    argument: (content: content, localPath: localPath),
    from: this,
  );

  @override
  String toString() => r'novelReaderViewModelProvider';
}

abstract class _$NovelReaderViewModel extends $Notifier<NovelReaderViewState> {
  late final _$args = ref.$arg as ({List<String>? content, String? localPath});
  List<String>? get content => _$args.content;
  String? get localPath => _$args.localPath;

  NovelReaderViewState build({
    required List<String>? content,
    required String? localPath,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NovelReaderViewState, NovelReaderViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NovelReaderViewState, NovelReaderViewState>,
              NovelReaderViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(content: _$args.content, localPath: _$args.localPath),
    );
  }
}
