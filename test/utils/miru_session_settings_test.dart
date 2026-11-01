import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('miru_session_settings');
    MiruSettings.sessionFilePathOverride =
        '${tempDir.path}/session_settings.json';
    MiruSettings.seedDefaultsForTest();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
    MiruSettings.sessionFilePathOverride = null;
  });

  test('a tracked write mirrors into the session file', () {
    MiruSettings.setSettingSync('Theme', 'dark');

    final written =
        jsonDecode(
              File(MiruSettings.sessionFilePathOverride!).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(written['Theme'], 'dark');
    expect(
      MiruSettings.getSettingSync<String>('Theme'),
      'dark',
      reason: 'cache stays the source the UI reads',
    );
  });

  test('untracked keys never land in the session file', () {
    MiruSettings.setSettingSync('DownloadPath', '/tmp/x');

    // No tracked write happened, so nothing was written at all.
    expect(File(MiruSettings.sessionFilePathOverride!).existsSync(), isFalse);
  });

  test('loadSessionSettings overrides the seeded defaults', () {
    File(
      MiruSettings.sessionFilePathOverride!,
    ).writeAsStringSync(jsonEncode({'Theme': 'light', 'Language': 'zh'}));

    // Simulate the bootstrap order: defaults first, session copy second.
    MiruSettings.seedDefaultsForTest();
    MiruSettings.loadSessionSettings();

    expect(MiruSettings.getSettingSync<String>('Theme'), 'light');
    expect(MiruSettings.getSettingSync<String>('Language'), 'zh');
    // Keys absent from the session file keep the default.
    expect(MiruSettings.getSettingSync<String>('BaseColor'), 'zinc');
  });

  test('a corrupt session file is ignored, not fatal', () {
    File(MiruSettings.sessionFilePathOverride!).writeAsStringSync('{oops');

    MiruSettings.loadSessionSettings();

    expect(
      MiruSettings.getSettingSync<String>('Theme'),
      'system',
      reason: 'cache keeps the seeded default',
    );
  });
}
