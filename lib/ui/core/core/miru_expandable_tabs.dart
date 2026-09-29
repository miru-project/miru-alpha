import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

class MiruExpandableTabEntry {
  const MiruExpandableTabEntry({required this.icon, required this.label});

  final Widget icon;
  final Widget label;
}

class MiruExpandableTabs extends StatelessWidget {
  final List<MiruExpandableTabEntry> children;
  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;
  final FTabsStyle Function(FTabsStyle style)? style;

  final double collapsedWidth;
  final double expandedWidth;
  final double height;
  final double iconSize;
  final BorderRadius radius;
  final double gap;

  const MiruExpandableTabs({
    super.key,
    required this.children,
    required this.selectedIndex,
    this.onIndexChanged,
    this.style,
    this.collapsedWidth = 45,
    this.expandedWidth = 200,
    this.height = 32,
    this.iconSize = 18,
    this.radius = const BorderRadius.all(Radius.circular(8)),
    this.gap = 8,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        this.style?.call(context.theme.tabsStyle) ?? context.theme.tabsStyle;
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: style.decoration,
      child: Padding(
        padding: style.padding,
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < children.length; i++)
                _ExpandableTab(
                  active: i == selectedIndex,
                  icon: children[i].icon,
                  label: children[i].label,
                  onTap: () => onIndexChanged?.call(i),
                  iconSize: iconSize,
                  collapsedWidth: collapsedWidth,
                  expandedWidth: expandedWidth,
                  height: height,
                  radius: radius,
                  focusedOutlineStyle: style.focusedOutlineStyle,
                  activeColor: colors.foreground,
                  inactiveColor: colors.mutedForeground,
                  pillColor: colors.background,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableTab extends StatefulWidget {
  final bool active;
  final Widget icon;
  final Widget label;
  final VoidCallback onTap;
  final double iconSize;
  final double collapsedWidth;
  final double expandedWidth;
  final double height;
  final BorderRadius radius;
  final FFocusedOutlineStyle focusedOutlineStyle;
  final Color activeColor;
  final Color inactiveColor;
  final Color pillColor;

  const _ExpandableTab({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconSize,
    required this.collapsedWidth,
    required this.expandedWidth,
    required this.height,
    required this.radius,
    required this.focusedOutlineStyle,
    required this.activeColor,
    required this.inactiveColor,
    required this.pillColor,
  });

  @override
  State<_ExpandableTab> createState() => _ExpandableTabState();
}

class _ExpandableTabState extends State<_ExpandableTab>
    with SingleTickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 400,
    damping: 30,
  );

  late final AnimationController _controller;
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: widget.active ? 1 : 0,
    );
    _focus.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _ExpandableTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      _controller.animateWith(
        SpringSimulation(_spring, _controller.value, widget.active ? 1 : 0, 0),
      );
    }
  }

  void _handleFocusChange() => setState(() => _focused = _focus.hasFocus);

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      widget.onTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.active,
      child: Focus(
        focusNode: _focus,
        onKeyEvent: _handleKeyEvent,
        child: FFocusedOutline(
          focused: _focused,
          style: widget.focusedOutlineStyle,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final spring = _controller.value;
                  final t = spring.clamp(0.0, 1.0);
                  final width = lerpDouble(
                    widget.collapsedWidth,
                    widget.expandedWidth,
                    spring,
                  )!.clamp(widget.collapsedWidth, double.infinity);
                  final color = Color.lerp(
                    widget.inactiveColor,
                    widget.activeColor,
                    t,
                  )!;
                  final labelAnim = _ClampedAnimation(_controller);
                  final collapsedPadding =
                      (widget.collapsedWidth - widget.iconSize) / 2;
                  final horizontalPadding = lerpDouble(
                    collapsedPadding < 0 ? 0 : collapsedPadding,
                    12,
                    t,
                  )!;

                  return ClipRRect(
                    borderRadius: widget.radius,
                    child: SizedBox(
                      width: width,
                      height: widget.height,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.active
                              ? widget.pillColor
                              : Colors.transparent,
                          borderRadius: widget.radius,
                          boxShadow: widget.active
                              ? const [
                                  BoxShadow(
                                    color: Color(0x16000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  size: widget.iconSize,
                                  color: color,
                                ),
                                child: widget.icon,
                              ),
                              Flexible(
                                child: SizeTransition(
                                  sizeFactor: labelAnim,
                                  axis: Axis.horizontal,
                                  alignment: .centerLeft,
                                  child: FadeTransition(
                                    opacity: labelAnim,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: DefaultTextStyle.merge(
                                          style: context
                                              .theme
                                              .typography
                                              .body
                                              .sm
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: color,
                                              ),
                                          child: widget.label,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClampedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _ClampedAnimation(this.parent);

  @override
  final Animation<double> parent;

  @override
  double get value => parent.value.clamp(0.0, 1.0);
}
