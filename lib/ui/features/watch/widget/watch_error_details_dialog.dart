import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The shared error-detail dialog: the full diagnostics dump (mono,
/// scrollable) with copy-to-clipboard. Popped from the in-player info
/// affordance of both failure cards (the extension-bridge card and the
/// loaded viewport's video-request card).
Future<void> showWatchErrorDetails(
  BuildContext context,
  String detailText,
) {
  return showFDialog(
    context: context,
    builder: (context, style, animations) => FDialog.adaptive(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 380),
      verticalBuilder: (context, style) =>
          _DetailsBody(style: style, detailText: detailText),
      horizontalBuilder: (context, style) =>
          _DetailsBody(style: style, detailText: detailText),
    ),
  );
}

/// The dialog's body: the diagnostics headline, the full dump in a
/// scrollable mono block, and the copy / close actions.
class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.style, required this.detailText});

  final FDialogStyle style;

  final String detailText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('watch.error_details'.i18n, style: style.titleTextStyle),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.theme.colors.muted.withAlpha(60),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.theme.colors.border.withAlpha(120),
                  ),
                ),
                child: Text(
                  detailText,
                  style: context.theme.typography.body.xs.copyWith(
                    fontFamily: 'monospace',
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Wrap, not Row: at 320-wide phones the dialog's inset padding
          // leaves ~200px — the actions flow to a second line instead of
          // spilling.
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 6,
            runSpacing: 6,
            children: [
              FButton(
                variant: .ghost,
                size: .xs,
                mainAxisSize: .min,
                onPress: () {
                  Clipboard.setData(ClipboardData(text: detailText));
                  showSimpleToast('watch.log_copied'.i18n);
                },
                prefix: const Icon(FLucideIcons.copy, size: 14),
                child: Flexible(
                  child: Text(
                    'watch.copy_log'.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              FButton(
                variant: .ghost,
                size: .xs,
                mainAxisSize: .min,
                onPress: () => Navigator.of(context).pop(),
                child: Text('common.cancel'.i18n),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
