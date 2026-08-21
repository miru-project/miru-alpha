import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';

/// Creates a [material_ui.TabController] that will be disposed automatically.
///
/// This mirrors the behavior of `flutter_hooks.useTabController` but returns a
/// `TabController` from the `material_ui` package so it is compatible with the
/// `material_ui` [TabBar], [TabBarView] (and therefore [MiruTabBar]).
TabController useMiruTabController({
  required int initialLength,
  int initialIndex = 0,
  Duration? animationDuration,
  List<Object?>? keys,
}) {
  final vsync = useSingleTickerProvider(keys: keys);

  return use(
    _MiruTabControllerHook(
      vsync: vsync,
      length: initialLength,
      initialIndex: initialIndex,
      animationDuration: animationDuration,
      keys: keys,
    ),
  );
}

class _MiruTabControllerHook extends Hook<TabController> {
  const _MiruTabControllerHook({
    required this.length,
    required this.vsync,
    required this.initialIndex,
    required this.animationDuration,
    super.keys,
  });

  final int length;
  final TickerProvider vsync;
  final int initialIndex;
  final Duration? animationDuration;

  @override
  HookState<TabController, Hook<TabController>> createState() =>
      _MiruTabControllerHookState();
}

class _MiruTabControllerHookState
    extends HookState<TabController, _MiruTabControllerHook> {
  late final controller = TabController(
    length: hook.length,
    initialIndex: hook.initialIndex,
    animationDuration: hook.animationDuration,
    vsync: hook.vsync,
  );

  @override
  TabController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useMiruTabController';
}
