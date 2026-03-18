import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import '../store/storage_index.dart';

final logger = Logger('Miru_alpha');

class MiruLog {
  static final logFilePath = path.join(MiruDirectory.getDirectory, 'miru.log');
  static final defaultLogFilePath = path.join(
    MiruDirectory.appSupportDirectory,
    'miru.log',
  );
  static bool hasInit = false;

  // Write log to the dir that contains the executable file
  static void defaultError(Object error, StackTrace stack) {
    File(
      defaultLogFilePath,
    ).writeAsStringSync('${error.toString()}\n${stack.toString()}');
  }

  static void _recordLog(LogRecord record) {
    try {
      final log =
          '${record.loggerName} ${record.level.name} ${record.time}: ${record.message} ${record.error ?? ''} ${record.stackTrace ?? ''}';
      debugPrint(log);
      // if (kReleaseMode) {
      Future.microtask(() => writeLogToFile(log)).catchError((e, s) {
        // Use debugPrint here to avoid triggering logger again.
        debugPrint('Failed to write log to file: $e');
        debugPrint(s.toString());
        defaultError(e, s);
      });
      // }
    } catch (e, s) {
      debugPrint('Logging listener error: $e');
      debugPrint(s.toString());
      defaultError(e, s);
    }
  }

  static void ensureInitialized() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(_recordLog);
    hasInit = true;
  }

  static void initForIsolate(SendPort sendPort) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      sendPort.send({
        'level': record.level.name,
        'message': record.message,
        'loggerName': record.loggerName,
        'time': record.time.toIso8601String(),
        'error': record.error?.toString(),
        'stackTrace': record.stackTrace?.toString(),
      });
    });
    hasInit = true;
  }

  // 写入日志到文件
  static void writeLogToFile(String log) {
    if (!(MiruSettings.getSetting<bool>(SettingKey.saveLog) ?? true)) {
      return;
    }
    final file = File(logFilePath);
    file.writeAsStringSync('$log\n', mode: FileMode.append);
    if (file.lengthSync() > 1024 * 1024 * 10) {
      file.deleteSync();
    }
  }
}
