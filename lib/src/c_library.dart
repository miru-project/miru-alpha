import 'package:native_toolchain_c/native_toolchain_c.dart';

CLibrary getCLibrary({
  List<String>? includes,
  List<String>? libraries,
  List<String>? libraryDirectories,
}) {
  return CLibrary(
    language: Language.cpp,
    name: 'ffmpeg_merge',
    assetName: 'src/ffmpeg_merge/ffmpeg_merge.g.dart',
    sources: ['src/ffmpeg_merge/cpp/main.cpp'],
    includes: includes ?? <String>[],
    libraries: libraries ?? <String>[],
    libraryDirectories: libraryDirectories ?? <String>[],
  );
}
