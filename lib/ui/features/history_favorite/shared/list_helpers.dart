import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/ui/core/dialog/dialog.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// Looks up the [ExtensionMeta] for [package] from the loaded extension list.
ExtensionMeta? findMeta(WidgetRef ref, String package) {
  return ref
      .read(extensionPageProvider)
      .metaData
      .where((e) => e.packageName == package)
      .firstOrNull;
}

/// Navigates to the detail page for the given [meta] and [url].
void openDetail(BuildContext context, ExtensionMeta meta, String url) {
  context.push(
    '/search/single/detail',
    extra: DetailParam(meta: meta, url: url),
  );
}

/// Opens a confirmation dialog and calls [onConfirm] when the user agrees.
Future<void> showDeleteConfirmDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String body,
  required VoidCallback onConfirm,
}) async {
  final confirmed = await showMiruDialog<bool>(
    context: context,
    title: Text(title),
    body: Text(body),
    actions: [
      FButton(
        variant: FButtonVariant.secondary,
        onPress: () => Navigator.pop(context, false),
        child: Text('common.cancel'.i18n),
      ),
      FButton(
        variant: FButtonVariant.destructive,
        onPress: () => Navigator.pop(context, true),
        child: Text('common.delete'.i18n),
      ),
    ],
  );
  if (confirmed == true) onConfirm();
}

/// Opens a bottom sheet with a single "remove" action.
void showRemoveSheet({
  required BuildContext context,
  required String title,
  required String actionLabel,
  required IconData actionIcon,
  required VoidCallback onRemove,
}) {
  showFSheet(
    context: context,
    side: .btt,
    builder: (context) => MiruCard(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 20,
        ),
        child: FTileGroup(
          label: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(title),
          ),
          children: [
            FTile(
              prefix: Icon(actionIcon),
              title: Text(actionLabel),
              onPress: () {
                Navigator.pop(context);
                onRemove();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
