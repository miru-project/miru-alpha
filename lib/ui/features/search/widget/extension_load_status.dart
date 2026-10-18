import 'package:miru_alpha/model/extension_meta_data.dart';

import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/dialog/dialog.dart';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// The load state of an installed extension, derived from [ExtensionMeta] the
/// same way on every surface: a backend load error, else the not-yet-loaded
/// heuristic (`api` empty). One owner so the mobile card and the desktop tile
/// cannot drift apart.
({String label, bool failed})? extensionLoadState(ExtensionMeta meta) {
  final error = meta.error?.trim();

  if (error != null && error.isNotEmpty) {
    return (label: error, failed: true);
  }

  if (meta.api.isEmpty) {
    return (label: 'extension.not_loaded'.i18n, failed: false);
  }

  return null;
}

/// The error dialog behind the card's error icon button: the red word plus the
/// backend's own message, wrapped.
Future<void> showExtensionError(BuildContext context, ExtensionMeta meta) {
  final state = extensionLoadState(meta);

  return showMiruDialog<void>(
    context: context,
    title: Text('extension.failed'.i18n),
    body: Text(
      state?.label ?? '',
      style: context.theme.typography.body.sm.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    ),
    actions: [
      FButton(
        variant: .outline,
        onPress: () => Navigator.of(context).pop(),
        child: Text('common.close'.i18n),
      ),
    ],
  );
}
