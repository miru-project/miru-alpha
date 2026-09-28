import 'dart:ui' show ImageFilter;

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_button.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Floating reader header: back affordance, title block, and the three
/// reader-level actions (bookmark, chapter list, settings).
///
/// Sits above the page canvas rather than in a [FScaffold] header so the manga
/// stays edge-to-edge underneath it.
class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onToggleChapters,
    required this.onOpenSettings,
    this.onToggleBookmark,
    this.bookmarked = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onToggleChapters;
  final VoidCallback onOpenSettings;
  final VoidCallback? onToggleBookmark;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ReaderBarChrome(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            ReaderIconAction(
              icon: FLucideIcons.chevronLeft,
              tooltip: 'reader.manga.back'.i18n,
              height: ReaderControlSize.medium,
              onPress: onBack,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reference: text-sm (14px) semibold title, text-xs (12px)
                  // muted subtitle.
                  ReaderLabel(
                    title,
                    style: context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  ReaderLabel(
                    subtitle,
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ReaderIconAction(
              icon: bookmarked
                  ? FLucideIcons.bookmarkCheck
                  : FLucideIcons.bookmark,
              tooltip: 'reader.manga.bookmark'.i18n,
              height: ReaderControlSize.medium,
              selected: bookmarked,
              onPress: onToggleBookmark,
            ),
            ReaderIconAction(
              icon: FLucideIcons.tableOfContents,
              tooltip: 'reader.manga.chapters'.i18n,
              height: ReaderControlSize.medium,
              onPress: onToggleChapters,
            ),
            ReaderIconAction(
              icon: FLucideIcons.settings,
              tooltip: 'reader.manga.settings'.i18n,
              height: ReaderControlSize.medium,
              onPress: onOpenSettings,
            ),
          ],
        ),
      ),
    );
  }
}

/// Opacity of the reader's frosted surfaces.
///
/// Lower than the 0.85/0.9 the chrome started at: the artwork behind it is
/// blurred now, so a more transparent surface shows more of the page without
/// making the labels any harder to read.
const kReaderBarAlpha = 0.68;
const kReaderPanelAlpha = 0.74;
const kReaderPillAlpha = 0.68;

/// Blur sigma behind the reader's translucent surfaces.
///
/// A translucent colour alone leaves the artwork legible *through* the chrome:
/// page text and speech bubbles sit under the panel and fight the labels. A
/// frosted surface is what the reader actually needs — recognisable, but clearly
/// behind glass.
const kReaderSurfaceBlur = 16.0;

/// A translucent reader surface: the artwork behind it, blurred, with the
/// surface colour and border on top.
class ReaderSurface extends StatelessWidget {
  const ReaderSurface({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius,
    this.border,
  });

  final Widget child;
  final Color color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
      ),
      child: child,
    );
    final radius = borderRadius;
    if (radius == null) {
      return ClipRect(
        child: BackdropFilter(filter: _blur, child: surface),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(filter: _blur, child: surface),
    );
  }

  /// One filter for the whole reader: rebuilt on every frame otherwise, and
  /// [ImageFilter.blur] allocates.
  static final _blur = ImageFilter.blur(
    sigmaX: kReaderSurfaceBlur,
    sigmaY: kReaderSurfaceBlur,
  );
}

/// Edge-to-edge header surface: the reference header is a full-width bar with
/// only a bottom hairline, **not** a floating card like [ReaderChrome].
class ReaderBarChrome extends StatelessWidget {
  const ReaderBarChrome({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ReaderSurface(
      color: colors.background.withValues(alpha: kReaderBarAlpha),
      border: Border(bottom: BorderSide(color: colors.border)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// Translucent, fully-bordered floating surface used by the reader's control
/// panel (the reference's `rounded-2xl` bottom sheet).
class ReaderChrome extends StatelessWidget {
  const ReaderChrome({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ReaderSurface(
      color: colors.background.withValues(alpha: kReaderPanelAlpha),
      borderRadius: .circular(16),
      border: Border.all(color: colors.border),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// Square icon button with a FORUI tooltip, used across the reader HUD.
class ReaderIconAction extends StatelessWidget {
  const ReaderIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPress,
    this.height = ReaderControlSize.compact,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPress;
  final double height;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (_, _) => Text(tooltip),
      child: ReaderButton(
        variant: selected ? .secondary : .ghost,
        height: height,
        square: true,
        onPress: onPress,
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        icon: Icon(icon, size: 18),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
