import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../store/storage_index.dart';

final logger = Logger('Miru_alpha');

/// Reader scroll diagnostics (POS / JUMP / SLV / PROVIDER / SHELL /
/// window_track lines). Off by default; enable with
/// `flutter run --dart-define=READER_DIAGNOSTICS=true`. A const, so a
/// disabled release build tree-shakes the calls away.
const bool kReaderDiagnostics = bool.fromEnvironment(
  'READER_DIAGNOSTICS',
  defaultValue: false,
);

/// Dedicated sink for the reader's scroll tracing (POS / JUMP / SLV /
/// PROVIDER / SHELL / window_track). The gate lives here rather than at the
/// ~30 call sites.
///
/// A child logger is used instead of setting a child `Level` — package:logging
/// throws for non-root levels unless `hierarchicalLoggingEnabled` is set, and
/// flipping that globally changes [MiruLog]'s behaviour. When the flag is off
/// this is a single boolean check per call; when on, records still flow
/// through [Logger.root.onRecord] into miru.log.
final diagLogger = Logger('Miru_alpha.diag');

/// Emits [message] only when [kReaderDiagnostics] is on.
void diag(String message, [Object? error, StackTrace? stackTrace]) {
  if (!kReaderDiagnostics) return;
  diagLogger.fine(message, error, stackTrace);
}

class MiruLog {
  static final logFilePath = path.join(MiruDirectory.getDirectory, 'miru.log');
  static final coreLogFilePath = path.join(
    MiruDirectory.getDirectory,
    'miru_core.log',
  );
  static final coreCrashLogFilePath = path.join(
    MiruDirectory.getDirectory,
    'miru_core_crash.log',
  );
  static final crashLogFilePath = path.join(
    MiruDirectory.getDirectory,
    'miru_crash.log',
  );
  static final defaultLogFilePath = path.join(
    MiruDirectory.appSupportDirectory,
    'miru.log',
  );
  static bool hasInit = false;

  // Write log to the dir that contains the executable file
  static void defaultError(Object error, StackTrace stack) {
    File(defaultLogFilePath)
        .writeAsStringSync('${error.toString()}\n${stack.toString()}');
  }

  static void _recordLog(LogRecord record) {
    try {
      final log =
          '${record.loggerName} ${record.level.name} ${record.time}: ${record.message} ${record.error ?? ''} ${record.stackTrace ?? ''}';
      debugPrint(log);
      Future.microtask(() => writeLogToFile(log)).catchError((e, s) {
        debugPrint('Failed to write log to file: $e');
        debugPrint(s.toString());
        defaultError(e, s);
      });
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

  static void recordCrash(
    Object error,
    StackTrace stack, {
    String source = 'flutter',
  }) {
    try {
      if (!(MiruSettings.getSetting<bool>(SettingKey.captureCrash) ?? true)) {
        return;
      }
      final entry =
          '[CRASH][$source] ${DateTime.now().toIso8601String()}\n'
          'error: $error\n'
          'stack:\n$stack\n'
          '----------------------------------------\n';
      File(crashLogFilePath)
          .writeAsStringSync(entry, mode: FileMode.append, flush: true);
      if (File(crashLogFilePath).lengthSync() > 1024 * 1024 * 5) {
        File(crashLogFilePath).deleteSync();
      }
    } catch (e, s) {
      debugPrint('Failed to record crash: $e');
      debugPrint(s.toString());
    }
  }

  /// all known log files that exist on disk
  static List<({String name, String path})> availableLogFiles() {
    final candidates = {
      'miru_alpha.log': logFilePath,
      'miru_core.log': coreLogFilePath,
      'miru_core_crash.log': coreCrashLogFilePath,
      'miru_crash.log': crashLogFilePath,
    };
    return [
      for (final e in candidates.entries)
        if (File(e.value).existsSync()) (name: e.key, path: e.value),
    ];
  }

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
