import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Shell UI state: the desktop sidebar's collapsed icon rail (header toggle /
/// Ctrl+B). Session-scoped — not persisted.
class SidebarCollapsed extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void set(bool value) => state = value;
}

final sidebarCollapsedProvider = NotifierProvider<SidebarCollapsed, bool>(
  SidebarCollapsed.new,
);
