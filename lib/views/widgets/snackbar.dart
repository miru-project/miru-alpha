import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

void showTextSnackBar({required BuildContext context, required String text}) {
  MoonToast.show(context, label: Text(text));
}

void showSnackBar({required BuildContext context, required Widget content}) {
  if (context.mounted) {
    MoonToast.show(context, label: content);
  }
}

void showErrorSnackBar({
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
