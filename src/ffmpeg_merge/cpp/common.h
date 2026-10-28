// Shared plumbing for the ffmpeg_merge native library: export macros and
// the FFmpeg error logger used by both the merge and DLNA-stream engines.
#ifndef FFMPEG_MERGE_COMMON_H
#define FFMPEG_MERGE_COMMON_H

#include <iostream>

extern "C" {
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libavutil/avutil.h"
#include "libavutil/error.h"
}

// Cross-platform export definition
#ifdef _WIN32
#define EXPORT extern "C" __declspec(dllexport)
#else
#define EXPORT                                                                 \
  extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

// Logs the FFmpeg error for `ret` and returns it unchanged so callers can
// propagate the failure instead of aborting the whole process. Previously
// this called `exit(EXIT_FAILURE)`, which killed the host Flutter/Dart
// process when invoked through FFI.
inline int check_error(int ret, const char *msg) {
  if (ret < 0) {
    char error[AV_ERROR_MAX_STRING_SIZE];
    av_strerror(ret, error, AV_ERROR_MAX_STRING_SIZE);
    std::cerr << msg << ": " << error << std::endl;
  }
  return ret;
}

#endif
