cmake_minimum_required(VERSION 3.10)
project(miru_new)

# Android native build is now handled by hook/build.dart via Dart hooks.
# The hook compiles ffmpeg_merge using the Android NDK CMake toolchain
# and registers the output as a CodeAsset.
# The Gradle externalNativeBuild block has been removed.
# add_subdirectory(../src/ffmpeg_merge/android ffmpeg_merge)
# add_dependencies(miru_core ffmpeg_merge)
