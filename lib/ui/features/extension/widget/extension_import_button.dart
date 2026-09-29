import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/dialog/extension_import_dialog.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// A "+" button that opens the extension import dialog (import locally or by
/// URL), mirroring the mobile extension import flow.
class ExtensionImportButton extends StatelessWidget {
  const ExtensionImportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: FButton(
        prefix: Icon(FLucideIcons.plus, size: 24),
        variant: .secondary,
        onPress: () => showExtensionImportDialog(context),
        child: Text('extension.import.title'.i18n),
      ),
    );
  }
}
