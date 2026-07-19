import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/ui/core/dialog/dialog.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:path/path.dart' as p;

/// Shows the extension import dialog, mirroring the mobile import flow.
///
/// Offers two options:
///  * Import by URL  - downloads the `.js`/`.go` file from the given link
///                    and copies it into [Core.extensionPath].
///  * Import Locally - opens the system file picker and copies the selected
///                    extension file into [Core.extensionPath].
Future<void> showExtensionImportDialog(BuildContext context) async {
  String? editValue;
  await showMiruDialog(
    context: context,
    title: Text('extension.import.title'.i18n),
    actions: [
      FButton(
        variant: .secondary,
        onPress: () async {
          if (editValue == null || editValue!.isEmpty) return;
          Navigator.of(context).pop();
          try {
            final filename = p.basename(editValue!);
            final reg = RegExp(r'^[\w.-]+\.(js|go)$');
            if (!reg.hasMatch(filename)) {
              showSimpleToast('Invalid extension name');
              return;
            }
            final targetDir = Directory(Core.extensionPath);
            if (!targetDir.existsSync()) {
              await targetDir.create(recursive: true);
            }
            final targetPath = p.join(Core.extensionPath, filename);
            await Dio().download(editValue!, targetPath);
            showSimpleToast('Install Success');
          } catch (e) {
            showSimpleToast('Install Failed: $e');
          }
        },
        child: Text('extension.import.import_by_url'.i18n),
      ),
      FButton(
        onPress: () async {
          Navigator.of(context).pop();
          try {
            final result = await FilePicker.pickFiles(
              type: .custom,
              allowedExtensions: ['js', 'go'],
            );
            if (result != null && result.files.single.path != null) {
              final pickedPath = result.files.single.path!;
              final filename = p.basename(pickedPath);
              final reg = RegExp(r'^\w.+\.\w+\.(js|go)$');
              if (!reg.hasMatch(filename)) {
                showSimpleToast('Invalid extension name');
                return;
              }
              final targetPath = p.join(Core.extensionPath, filename);
              final targetDir = Directory(Core.extensionPath);
              if (!targetDir.existsSync()) {
                await targetDir.create(recursive: true);
              }
              await File(pickedPath).copy(targetPath);
              showSimpleToast('Install Success');
            }
          } catch (e) {
            showSimpleToast('Install Failed: $e');
          }
        },
        child: Text('extension.import.import_by_local'.i18n),
      ),
    ],
    body: Form(
      child: Column(
        mainAxisSize: .min,
        children: [
          Text('extension.import.tips'.i18n),
          SizedBox(height: 10),
          FTextFormField(
            autovalidateMode: .onUserInteraction,
            validator: (value) =>
                ((value?.startsWith('https') ?? false) ||
                        (value?.startsWith('http') ?? false)) &&
                    ((value?.endsWith('.js') ?? false) ||
                        (value?.endsWith('.go') ?? false))
                    ? null
                    : 'extension.import.invalid_url'.i18n,
            hint: 'https://example.com/ext.js',
            control: .managed(
              onChange: (value) {
                editValue = value.text;
              },
            ),
          ),
        ],
      ),
    ),
  );
}
