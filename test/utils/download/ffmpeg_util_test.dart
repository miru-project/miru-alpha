@Tags(['ffi'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';

void main() {
  group('FFMpegUtils.combineToMp4Async', () {
    // The test binary has no ffmpeg_merge native library, so the merge must
    // fail — what this pins down is that failures propagate across the
    // isolate boundary and never wedge the serialization queue.
    test('propagates worker-isolate errors to the caller', () async {
      await expectLater(
        FFMpegUtils.combineToMp4Async(['fake.ts'], 'out.mp4'),
        throwsA(anything),
      );
    });

    test('concurrent merges are queued, not deadlocked', () async {
      // If the gate leaked a completer on failure, the second call would
      // await forever and this test would time out.
      final results = await Future.wait([
        FFMpegUtils.combineToMp4Async(['a.ts'], 'out1.mp4').catchError((_) {}),
        FFMpegUtils.combineToMp4Async(['b.ts'], 'out2.mp4').catchError((_) {}),
      ]);
      expect(results.length, 2);
    });
  });
}
