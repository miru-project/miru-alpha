import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../../');
  FfiGenerator(
    input: Input(
      // include: (uri)=>uri.includeSet({'start'}),
      entryPoints: [packageRoot.resolve('src/ffmpeg_merge/cpp/main.h')],
    ),

    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/src/ffmpeg_merge/ffmpeg_merge.g.dart'),
      ),
    ),
  ).generate();
}
