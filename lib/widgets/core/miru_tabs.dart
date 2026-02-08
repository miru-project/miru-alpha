import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class MiruTabs extends StatefulWidget {
  final List<FTabEntry> children;
  final int initialIndex;
  final FTabsStyle Function(FTabsStyle style)? style;
  final TabController? controller;
  const MiruTabs({
    super.key,
    required this.children,
    this.initialIndex = 0,
    this.style,
    this.controller,
    this.onChanged,
  });

  final ValueChanged<int>? onChanged;

  @override
  State<MiruTabs> createState() => _MiruTabsState();
}

class _MiruTabsState extends State<MiruTabs>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        TabController(
          length: widget.children.length,
          vsync: this,
          initialIndex: widget.initialIndex,
        );
    _controller.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_controller.indexIsChanging) return;
    widget.onChanged?.call(_controller.index);
  }

  @override
  void didUpdateWidget(covariant MiruTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _controller.dispose();
      _controller = TabController(
        length: widget.children.length,
        vsync: this,
        initialIndex: widget.initialIndex,
      );
      _controller.addListener(_handleTabChange);
    } else if (widget.initialIndex != oldWidget.initialIndex) {
      _controller.animateTo(widget.initialIndex);
      widget.onChanged?.call(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final style =
        widget.style?.call(context.theme.tabsStyle) ?? context.theme.tabsStyle;

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          DecoratedBox(
            decoration: style.decoration,
            child: TabBar(
              tabs: [
                for (final tab in widget.children)
                  _MiruTab(style: style, label: tab.label),
              ],
              controller: _controller,
              padding: style.padding,
              indicator: style.indicatorDecoration,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              splashFactory: NoSplash.splashFactory,
              labelStyle: style.selectedLabelTextStyle,
              unselectedLabelStyle: style.unselectedLabelTextStyle,
            ),
          ),
          SizedBox(height: style.spacing),
          Expanded(
            child: DefaultTextStyle(
              style: theme.typography.base.copyWith(
                fontFamily: theme.typography.defaultFontFamily,
                color: theme.colors.foreground,
              ),
              child: TabBarView(
                controller: _controller,
                children: widget.children.map((e) => e.child).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiruTab extends StatefulWidget {
  final FTabsStyle style;
  final Widget label;

  const _MiruTab({required this.style, required this.label});

  @override
  State<_MiruTab> createState() => _MiruTabState();
}

class _MiruTabState extends State<_MiruTab> {
  FocusNode? _focus;
  bool _focused = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updated = Focus.of(context);
    if (_focus != updated) {
      _focus?.removeListener(_handleFocusChange);
      _focus = updated..addListener(_handleFocusChange);
    }
  }

  @override
  Widget build(BuildContext _) => FFocusedOutline(
    style: widget.style.focusedOutlineStyle.call,
    focused: _focused,
    child: Tab(height: widget.style.height, child: widget.label),
  );

  void _handleFocusChange() =>
      setState(() => _focused = _focus?.hasFocus ?? false);

  @override
  void dispose() {
    _focus?.removeListener(_handleFocusChange);
    super.dispose();
  }
}
