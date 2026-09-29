import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/miru_directory.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

/// Export one of the application's log files to the user.
///
/// On desktop a save dialog is presented via [FilePicker]; on mobile the
/// system share sheet is used instead.
Future<void> exportLogFile(String name, String sourcePath) async {
  final file = File(sourcePath);
  if (!file.existsSync()) {
    showSimpleToast('settings.logging.file_missing'.i18n);
    return;
  }

  if (Platform.isAndroid || Platform.isIOS) {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(sourcePath, name: name)],
          subject: name,
          text: 'settings.logging.share_text'.i18n,
        ),
      );
    } catch (e) {
      showSimpleToast('settings.logging.export_failed'.i18n);
    }
    return;
  }

  try {
    final bytes = await file.readAsBytes();
    final uri = await FilePicker.saveFile(
      dialogTitle: 'settings.logging.export_title'.i18n,
      fileName: name,
      bytes: bytes,
    );
    if (uri == null) return;
    try {
      await File.fromUri(uri).writeAsBytes(bytes);
    } catch (_) {
      // some platforms already persisted `bytes` to the uri
    }
    showSimpleToast('settings.logging.exported'.i18n);
  } catch (e) {
    showSimpleToast('settings.logging.export_failed'.i18n);
  }
}

/// export miru_alpha (Flutter) log
Future<void> exportMiruAlphaLog() =>
    exportLogFile('miru_alpha.log', MiruLog.logFilePath);

/// export miru_core (Go backend) log
Future<void> exportMiruCoreLog() =>
    exportLogFile('miru_core.log', MiruLog.coreLogFilePath);

/// export miru_core (Go backend) crash log (panics / fatal errors)
Future<void> exportMiruCoreCrashLog() =>
    exportLogFile('miru_core_crash.log', MiruLog.coreCrashLogFilePath);

/// export captured crash log
Future<void> exportCrashLog() =>
    exportLogFile('miru_crash.log', MiruLog.crashLogFilePath);

/// bundle every available log into a single file and export it
Future<void> exportAllLogs() async {
  final files = MiruLog.availableLogFiles();
  if (files.isEmpty) {
    showSimpleToast('settings.logging.file_missing'.i18n);
    return;
  }
  final buffer = StringBuffer();
  for (final file in files) {
    buffer.writeln('===== ${file.name} =====');
    try {
      buffer.writeln(await File(file.path).readAsString());
    } catch (_) {
      buffer.writeln('(unreadable)');
    }
    buffer.writeln();
  }
  final combined = File(
    path.join(MiruDirectory.getCacheDirectory, 'miru_all_logs.txt'),
  );
  await combined.writeAsString(buffer.toString());
  await exportLogFile('miru_all_logs.txt', combined.path);
}
