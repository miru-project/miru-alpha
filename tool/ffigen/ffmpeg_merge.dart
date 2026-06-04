import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../../');
  FfiGenerator(
    headers: Headers(
      entryPoints: [packageRoot.resolve('src/ffmpeg_merge/cpp/main.h')],
    ),
    functions: Functions.includeSet({'start'}),
    output: Output(
      dartFile: packageRoot.resolve('lib/src/ffmpeg_merge/ffmpeg_merge.g.dart'),
    ),
  ).generate();
}
