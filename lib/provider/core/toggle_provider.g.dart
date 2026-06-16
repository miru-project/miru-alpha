// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ToggleNotifier)
final toggleProvider = ToggleNotifierFamily._();

final class ToggleNotifierProvider
    extends $NotifierProvider<ToggleNotifier, bool> {
  ToggleNotifierProvider._({
    required ToggleNotifierFamily super.from,
    required bool? super.argument,
  }) : super(
         retry: null,
         name: r'toggleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$toggleNotifierHash();

  @override
  String toString() {
    return r'toggleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ToggleNotifier create() => ToggleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ToggleNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$toggleNotifierHash() => r'0348bfffbbe8a9a0f25d2d9294c23b139832a188';

final class ToggleNotifierFamily extends $Family
    with $ClassFamilyOverride<ToggleNotifier, bool, bool, bool, bool?> {
  ToggleNotifierFamily._()
    : super(
        retry: null,
        name: r'toggleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ToggleNotifierProvider call(bool? initValue) =>
      ToggleNotifierProvider._(argument: initValue, from: this);

  @override
  String toString() => r'toggleProvider';
}

abstract class _$ToggleNotifier extends $Notifier<bool> {
  late final _$args = ref.$arg as bool?;
  bool? get initValue => _$args;

  bool build(bool? initValue);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
