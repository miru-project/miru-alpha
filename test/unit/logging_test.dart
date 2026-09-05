import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/utils/core/log.dart';

/// MiruLog writes `miru.log` from a single `Logger.root.onRecord` listener, and
/// the in-app Settings -> Logging -> Export screens ship that file to support.
/// Anything that does not propagate to the root listener is therefore invisible
/// when debugging a user report.
///
/// `dart:developer`'s `log` is exactly such a logger — it never enters
/// package:logging at all. That is why the project standard is package:logging
/// everywhere, and why subsystem tags are expressed as child loggers rather
/// than by leaving the tree.
void main() {
  test(
    'subsystem loggers reach the root listener MiruLog writes from',
    () async {
      final records = <LogRecord>[];
      final subscription = Logger.root.onRecord.listen(records.add);
      addTearDown(subscription.cancel);

      Logger('${logger.name}.router').warning('Ignoring unknown ?type="bogus"');
      await Future<void>.delayed(Duration.zero);

      expect(records, hasLength(1));
      expect(records.single.level, Level.WARNING);
      // The record keeps a subsystem tag, which was the one thing dart:developer
      // offered and the plain app logger did not.
      expect(records.single.loggerName, '${logger.name}.router');
      expect(records.single.message, contains('?type="bogus"'));
    },
  );

  test('a dotted name is parented to the app logger', () {
    final child = Logger('${logger.name}.router');

    expect(child.parent, same(logger));
    expect(child.fullName, '${logger.name}.router');
  });

  test('severe records carry the error and stack trace as fields', () async {
    final records = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(records.add);
    addTearDown(subscription.cancel);

    final failure = StateError('boom');
    Logger('${logger.name}.network').severe('Failed to fetch data', failure);
    await Future<void>.delayed(Duration.zero);

    expect(records, hasLength(1));
    // Interpolating the error into the message string is what the old guidance
    // encouraged; passing it as an argument keeps it structured for MiruLog.
    expect(records.single.error, same(failure));
  });
}
