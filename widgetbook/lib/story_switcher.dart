import 'dart:async';
import 'dart:convert';
import 'dart:io';

// The catalog's own design system is material_ui; widgetbook itself is built
// on material_ui, so use it here too (package:flutter/material.dart is
// deprecated in this SDK).
// ignore: depend_on_referenced_packages
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Agent-driven story switcher for the miru Widgetbook.
///
/// The agent writes a story path (the same string the deep-link uses) to
/// [storyFile]. This wrapper polls that file; when it changes, it rebuilds
/// the catalog with a fresh `key` so the widgetbook re-reads its
/// `initialRoute` and boots straight into the selected story — no relaunch,
/// no manual tapping in the sidebar.
///
/// The rebuild-and-rekey approach (rather than calling the internal
/// `WidgetbookState.updatePath`) is deliberate: `updatePath` is `@internal`
/// and `appBuilder` only wraps the use-case preview, not the navigation
/// shell, so a wrapper around the whole `Widgetbook.material` with a
/// changing key is the only reliable public hook.
///
/// The file is polled (not `watch`ed) because `File.watch` needs the file to
/// exist up front and misses rewrites in some editors; a 300ms poll is cheap
/// and reliable across `dart run`, hot reload and relaunch.
const String storyFile = '/tmp/miru_wb_story';

/// Wraps the Widgetbook app so it can react to [storyFile] changes.
class StorySwitcher extends StatefulWidget {
  const StorySwitcher({super.key, required this.builder});

  /// Builds the catalog for a given story path (the `initialRoute`). Called
  /// again with a new key whenever the agent selects a different story.
  final Widget Function(String storyPath) builder;

  @override
  State<StorySwitcher> createState() => _StorySwitcherState();
}

class _StorySwitcherState extends State<StorySwitcher> {
  Timer? _poll;
  String _current = '';
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _current = _readStory();
    _poll = Timer.periodic(const Duration(milliseconds: 300), _check);
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  String _readStory() {
    try {
      return File(storyFile).readAsStringSync().trim();
    } catch (_) {
      return '';
    }
  }

  void _check(Timer _) {
    final next = _readStory();
    if (next == _current) return;
    _current = next;
    setState(() => _generation++);
  }

  @override
  Widget build(BuildContext context) {
    // Re-key on every selection so Widgetbook re-reads initialRoute and
    // rebuilds its router around the new story path.
    return KeyedSubtree(
      key: ValueKey('wb-gen-$_generation'),
      child: widget.builder(_current),
    );
  }
}

/// Dumps the full story tree to [treeFile] so an agent can `list` every
/// screen without scraping source. Mounted inside the widgetbook (so it can
/// read [WidgetbookState]) via the `home` slot — it renders nothing visible.
class TreeDumper extends StatefulWidget {
  const TreeDumper({super.key, required this.child});

  final Widget child;

  @override
  State<TreeDumper> createState() => _TreeDumperState();
}

class _TreeDumperState extends State<TreeDumper> {
  static const _treeFile = '/tmp/miru_wb_tree.json';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), _dump);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dump(Timer _) {
    final state = WidgetbookState.maybeOf(context);
    if (state == null) return;
    final paths = state.root.leaves.map((leaf) => leaf.path).toList()..sort();
    try {
      // jsonEncode per path: some use-case names carry literal `"` (e.g.
      // `Play CTA — no history ("Play ep. 1")`) which would break a naive
      // `'"$p"'` join.
      File(_treeFile).writeAsStringSync(
        paths.map(jsonEncode).join(',\n'),
        mode: FileMode.write,
      );
    } catch (_) {
      // Best-effort; the poll retries next tick.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
