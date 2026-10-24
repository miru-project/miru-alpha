import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/foundation.dart';

class AnimatedBox extends HookWidget {
  const AnimatedBox({
    required this.child,
    this.onTap,
    this.onLongPress,
    super.key,
  }) : horizontalPadding = 10,
       verticalPadding = 5;
  const AnimatedBox.nopadding({
    required this.child,
    this.onTap,
    this.onLongPress,
    super.key,
  }) : horizontalPadding = 0,
       verticalPadding = 0;
  final Widget child;
  final VoidCallback? onTap;

  /// Long-press action (e.g. a remove sheet on home rails); FTappable
  /// already owns the gesture, so no extra detector is layered on.
  final VoidCallback? onLongPress;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: FTappable(
        behavior: .translucent,
        onPress: onTap,
        onLongPress: onLongPress,
        child: RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              boxShadow: isHovered.value
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            // LayoutBuilder captures parent constraints, then we scale within fixed bounds
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : null,
                  height: constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : null,
                  child: ExcludeSemantics(
                    child: AnimatedScale(
                      scale: isHovered.value ? 1.02 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
