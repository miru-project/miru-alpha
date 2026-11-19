import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';
import 'package:miru_alpha/utils/update/update_installer.dart';

/// The release body, rendered.
///
/// GitHub writes a release body as Markdown (headings, task lists, tables,
/// fenced code), so it has to be parsed rather than printed: a raw body shows
/// the reader `## What's new` and `- item` instead of the section it describes.
/// [flutter_markdown_plus] is the maintained continuation of Google's
/// discontinued `flutter_markdown` (same API, upstream still ships fixes).
///
/// Styling is the app's type scale, not Material's defaults: every level is
/// mapped onto forui's typography so a release note reads like the rest of the
/// app instead of like a web page pasted into a dialog.
class UpdateChangelog extends StatelessWidget {
  const UpdateChangelog({
    super.key,
    required this.markdown,
    this.maxHeight,
    this.padding = EdgeInsets.zero,
  });

  /// The raw release body.
  final String markdown;

  /// Bounds the rendered notes. A release body is unbounded in length and the
  /// dialog that hosts it is not, so the notes scroll inside this height
  /// instead of pushing the actions off screen.
  final double? maxHeight;

  final EdgeInsets padding;

  bool get _isBlank => markdown.trim().isEmpty;

  @override
  Widget build(BuildContext context) {
    final content = _isBlank
        ? Text(
            'settings.update.no_release_notes'.i18n,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
              height: 1.5,
            ),
          )
        : MarkdownBody(
            data: markdown,
            selectable: true,
            styleSheet: _styleSheet(context),
            // Links belong to the changelog's own text (issue #1234, a docs
            // page); a tap opens them in the browser rather than nowhere.
            onTapLink: (text, href, title) {
              if (href == null || href.isEmpty) return;
              UpdateInstaller.openReleasePage(href);
            },
          );

    return Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: maxHeight == null
            ? const BoxConstraints()
            : BoxConstraints(maxHeight: maxHeight!),
        child: SingleChildScrollView(child: content),
      ),
    );
  }

  /// forui's scale, applied to each Markdown element.
  MarkdownStyleSheet _styleSheet(BuildContext context) {
    final theme = context.theme;
    final typography = theme.typography;
    final colors = theme.colors;

    return MarkdownStyleSheet(
      p: typography.body.sm.copyWith(color: colors.foreground, height: 1.55),
      // One step down the app's scale per level, not forui's display scale:
      // `display.xl3` is 30px, which made a GitHub "## What's new" shout over
      // a 15px dialog title inside a 370px card. A release body is content, so
      // it is set like content — `body.*`, bold, with the heading step coming
      // from the size and not from shouting.
      h1: typography.body.xl.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: typography.body.lg.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      h3: typography.body.md.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w700,
        height: 1.4,
      ),
      h4: typography.body.md.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      h5: typography.body.sm.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
      h6: typography.body.sm.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
      h1Padding: const EdgeInsets.only(bottom: 6),
      h2Padding: const EdgeInsets.only(bottom: 6),
      h3Padding: const EdgeInsets.only(bottom: 4),
      h4Padding: const EdgeInsets.only(bottom: 4),
      h5Padding: const EdgeInsets.only(bottom: 4),
      h6Padding: const EdgeInsets.only(bottom: 4),
      strong: typography.body.sm.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w700,
        height: 1.55,
      ),
      em: typography.body.sm.copyWith(
        color: colors.foreground,
        fontStyle: FontStyle.italic,
        height: 1.55,
      ),
      del: typography.body.sm.copyWith(
        color: colors.mutedForeground,
        decoration: TextDecoration.lineThrough,
        height: 1.55,
      ),
      code: typography.body.sm.copyWith(
        color: colors.foreground,
        fontFamily: 'monospace',
        fontFamilyFallback: const ['DejaVu Sans Mono', 'Liberation Mono'],
        height: 1.4,
      ),
      listBullet: typography.body.sm.copyWith(
        color: colors.foreground,
        height: 1.55,
      ),
      listIndent: 18,
      blockSpacing: 10,
      blockquote: typography.body.sm.copyWith(
        color: colors.mutedForeground,
        height: 1.55,
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      blockquoteDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: colors.primary, width: 3)),
      ),
      codeblockPadding: const EdgeInsets.all(10),
      codeblockDecoration: BoxDecoration(
        color: colors.muted.withAlpha(60),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      tableBorder: TableBorder.all(
        color: colors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      tableHead: typography.body.xs.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w700,
      ),
      tableBody: typography.body.sm.copyWith(color: colors.foreground),
    );
  }
}

/// The release notes, on their own, opened from the banner's *Release notes*
/// action.
///
/// The banner used to hand off to the browser for this; a note about the build
/// being installed should not need a network round trip to read.
Future<void> showUpdateChangelogDialog(
  BuildContext context, {
  required MiruRelease release,

  /// See [showUpdateAvailableDialog] — the catalog's phone frame passes
  /// `false` so the notes land on the phone's back stack.
  bool useRootNavigator = true,
}) {
  return showFDialog(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (context, style, _) => FDialog.adaptive(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 520),
      semanticsLabel: 'settings.update.changelog'.i18n,
      verticalBuilder: (context, style) =>
          _ChangelogDialog(style: style, release: release),
      horizontalBuilder: (context, style) =>
          _ChangelogDialog(style: style, release: release),
    ),
  );
}

class _ChangelogDialog extends StatelessWidget {
  const _ChangelogDialog({required this.style, required this.release});

  final FDialogStyle style;
  final MiruRelease release;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'settings.update.changelog'.i18n,
                  style: style.titleTextStyle,
                ),
              ),
              Text(
                release.version,
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Flexible(
            child: UpdateChangelog(markdown: release.body, maxHeight: 380),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 6,
            runSpacing: 6,
            children: [
              FButton(
                variant: .ghost,
                size: .sm,
                mainAxisSize: .min,
                onPress: () => Navigator.of(context).pop(),
                child: Text('settings.update.close'.i18n),
              ),
              FButton(
                variant: .ghost,
                size: .sm,
                mainAxisSize: .min,
                onPress: () async {
                  final opened = await UpdateInstaller.openReleasePage(
                    release.htmlUrl,
                  );
                  if (opened && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text('settings.update.view_on_github'.i18n),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
