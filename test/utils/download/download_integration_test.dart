import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/utils/download/download_utils.dart';
import 'package:path/path.dart' as p;

/// Simulates a download that only produces progress updates without any
/// network/HTTP request. Bytes are written locally into [output] (the temp
/// landing file) and the reported progress percentages are returned.
List<int> simulateDownloadProgress({
  required int totalBytes,
  required File output,
}) {
  const chunk = 1024;
  final progress = <int>[];
  var written = 0;
  while (written < totalBytes) {
    final step = totalBytes - written < chunk ? totalBytes - written : chunk;
    output.writeAsBytesSync(List.filled(step, 0xAB), mode: FileMode.append);
    written += step;
    progress.add(written * 100 ~/ totalBytes);
  }
  return progress;
}

void main() {
  group('Download integration (frontend file flow, no network)', () {
    late Directory root;

    setUp(() => root = Directory.systemTemp.createTempSync('dl_integration_'));
    tearDown(() => root.deleteSync(recursive: true));

    test(
      'reports progress, saves into nested path, removes temp file',
      () async {
        // 1) Backend temp location where partial data lands.
        final tempDir = Directory.systemTemp.createTempSync('dl_temp_');
        final tempFile = File(p.join(tempDir.path, 'partial.bin'));
        tempFile.createSync();

        // 2) Simulate progress reporting — no request sent to any server.
        final progress = simulateDownloadProgress(
          totalBytes: 5 * 1024 * 1024,
          output: tempFile,
        );
        expect(progress.first, 0);
        expect(progress.last, 100);

        // 3) Save using the same frontend primitives the app uses. handleFile
        //    computes the nested target path the UI expects.
        final targetPath = await DownloadUtils.handleFile(
          taskId: '42',
          currentPath: tempFile.path,
          targetDir: root.path,
          isHls: false,
          title: 'My Anime',
          category: proto.DownloadCategory.video,
          package: 'test.pkg',
          epKey: 'Episode 1',
        );

        // Frontend perspective: $root/Bangumi/<package>/<title>/<episode>.<ext>
        final expected = p.join(
          root.path,
          'Bangumi',
          'test.pkg',
          'My Anime',
          'Episode 1.bin',
        );
        expect(targetPath, equals(expected));
        expect(await Directory(p.dirname(targetPath)).exists(), isTrue);

        // Finalize: copy temp download into the nested location (what
        // processFinishedDownload does for non-HLS).
        await tempFile.copy(targetPath);

        // 4) Temp cleanup (mirrors the notifier's _cleanupTempFiles).
        DownloadUtils.safeDeletePath(tempFile.path);
        expect(tempFile.existsSync(), isFalse);
        // Parent temp dir is gone too (empty after removal).
        expect(tempDir.existsSync(), isFalse);

        // 5) Final file exists at the correct nested path with full size.
        final saved = File(targetPath);
        expect(saved.existsSync(), isTrue);
        expect(await saved.length(), 5 * 1024 * 1024);
      },
    );
  });
}
