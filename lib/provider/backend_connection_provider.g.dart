// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend_connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global backend gate.
///
/// The init page is gone: the app renders immediately and every backend
/// operation waits on [backendConnectionProvider.future] instead of a splash
/// screen. The build resolves only once [Core.ensureInitialized] succeeds
/// (gRPC `helloMiru` answered, settings loaded) and re-applies the user's
/// persisted theme/language, which until then run on the synchronous defaults
/// seeded at bootstrap.
///
/// While it pends, surfaces show their per-operation loading states and the
/// home/desktop title bars render the connecting status
/// ([BackendConnectionTitle]).

@ProviderFor(BackendConnection)
final backendConnectionProvider = BackendConnectionProvider._();

/// Global backend gate.
///
/// The init page is gone: the app renders immediately and every backend
/// operation waits on [backendConnectionProvider.future] instead of a splash
/// screen. The build resolves only once [Core.ensureInitialized] succeeds
/// (gRPC `helloMiru` answered, settings loaded) and re-applies the user's
/// persisted theme/language, which until then run on the synchronous defaults
/// seeded at bootstrap.
///
/// While it pends, surfaces show their per-operation loading states and the
/// home/desktop title bars render the connecting status
/// ([BackendConnectionTitle]).
final class BackendConnectionProvider
    extends $AsyncNotifierProvider<BackendConnection, void> {
  /// Global backend gate.
  ///
  /// The init page is gone: the app renders immediately and every backend
  /// operation waits on [backendConnectionProvider.future] instead of a splash
  /// screen. The build resolves only once [Core.ensureInitialized] succeeds
  /// (gRPC `helloMiru` answered, settings loaded) and re-applies the user's
  /// persisted theme/language, which until then run on the synchronous defaults
  /// seeded at bootstrap.
  ///
  /// While it pends, surfaces show their per-operation loading states and the
  /// home/desktop title bars render the connecting status
  /// ([BackendConnectionTitle]).
  BackendConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backendConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backendConnectionHash();

  @$internal
  @override
  BackendConnection create() => BackendConnection();
}

String _$backendConnectionHash() => r'f840aa496ebc1e0f28884b715521e43c9db5fa02';

/// Global backend gate.
///
/// The init page is gone: the app renders immediately and every backend
/// operation waits on [backendConnectionProvider.future] instead of a splash
/// screen. The build resolves only once [Core.ensureInitialized] succeeds
/// (gRPC `helloMiru` answered, settings loaded) and re-applies the user's
/// persisted theme/language, which until then run on the synchronous defaults
/// seeded at bootstrap.
///
/// While it pends, surfaces show their per-operation loading states and the
/// home/desktop title bars render the connecting status
/// ([BackendConnectionTitle]).

abstract class _$BackendConnection extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
