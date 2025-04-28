import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

showTextSnackBar({required BuildContext context, required String text}) {
  MoonToast.show(context, label: Text(text));
}

showSnackBar({required BuildContext context, required Widget content}) {
  if (context.mounted) {
    MoonToast.show(context, label: content);
  }
}

showErrorSnackBar({
  required BuildContext context,
  required String errorText,
  required String detailErrortext,
}) {
  MoonToast.show(
    context,
    label: Text(errorText),
    trailing: Row(
      children: [
        MoonButton.icon(
          icon: const Text("Copy Message"),
          onTap: () => Clipboard.setData(ClipboardData(text: detailErrortext)),
        ),
      ],
    ),
  );
}
