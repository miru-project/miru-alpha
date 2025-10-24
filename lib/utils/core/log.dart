
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import '../store/storage_index.dart';

final logger = Logger('Miru');

class MiruLog {
  static final logFilePath = path.join(MiruDirectory.getDirectory, 'miru.log');

  static void ensureInitialized() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      try {
        final log =
            '${record.loggerName} ${record.level.name} ${record.time}: ${record.message} ${record.error ?? ''} ${record.stackTrace ?? ''}';
        debugPrint(log);
        // if (kReleaseMode) {
        //   Future.microtask(() => writeLogToFile(log)).catchError((e, s) {
        //     // Use debugPrint here to avoid triggering logger again.
        //     debugPrint('Failed to write log to file: $e');
        //     debugPrint(s.toString());
        //   });
        // }
      } catch (e, s) {
        debugPrint('Logging listener error: $e');
        debugPrint(s.toString());
      }
    });
  }

  // 写入日志到文件
  // static void writeLogToFile(String log) {
  //   if (!MiruSettings.getSettingSync<bool>(SettingKey.saveLog)) {
  //     return;
  //   }
  //   final file = File(logFilePath);
  //   file.writeAsStringSync('$log\n', mode: FileMode.append);
  //   if (file.lengthSync() > 1024 * 1024 * 10) {
  //     file.deleteSync();
  //   }
  // }
}
