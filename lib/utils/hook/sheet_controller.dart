import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

SheetController useSheetController({List<Object?>? keys}) {
  return use(_ScrollControllerHook(keys: keys));
}

class _ScrollControllerHook extends Hook<SheetController> {
  const _ScrollControllerHook({super.keys});

  @override
  HookState<SheetController, Hook<SheetController>> createState() =>
      _ScrollControllerHookState();
}

class _ScrollControllerHookState
    extends HookState<SheetController, _ScrollControllerHook> {
  late final controller = SheetController();

  @override
  SheetController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useSheetScrollController';
}
