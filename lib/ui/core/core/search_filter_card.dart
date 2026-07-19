import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/core/core/blur.dart';
import 'package:miru_alpha/ui/core/dialog/extension_import_dialog.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class SearchFilterCard extends StatelessWidget {
  final Widget child;
  final Widget? trailing;
  const SearchFilterCard({super.key, required this.child, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Blur(
      borderRadius: context.theme.style.borderRadius.md,
      child: MiruCard(
        style: .delta(
          decoration: .boxDelta(
            borderRadius: context.theme.style.borderRadius.md,
            color: context.theme.colors.background.withAlpha(200),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: child),
              trailing ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A "+" button that opens the extension import dialog (import locally or by
/// URL), mirroring the mobile extension import flow.
class SearchFilterImportButton extends StatelessWidget {
  const SearchFilterImportButton({super.key});
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
