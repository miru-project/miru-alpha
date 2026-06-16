import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_provider.g.dart';

@riverpod
class ToggleNotifier extends _$ToggleNotifier {
  @override
  bool build(bool? initValue) {
    return initValue ?? false;
  }

  void toggle() => state = !state;
  void setTrue() => state = true;
  void setFalse() => state = false;
  void setValue(bool value) => state = value;
}
