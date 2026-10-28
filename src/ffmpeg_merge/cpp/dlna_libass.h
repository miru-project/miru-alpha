// libass-direct subtitle burn: loads libass at runtime via dlopen/dlsym (no
// build-time dependency) and composites ASS/SRT subtitles onto decoded
// YUV420P frames before the encoder. This is the burn path wherever the
// linked ffmpeg lacks the ass/subtitles filters (avbuild android/windows):
// the libass.so shipped inside the app (fvp's mdk-sdk on android, the system
// library on linux) is used as-is.
//
// Threading: all calls happen on the stream's worker isolate, like the rest
// of the engine.
#ifndef FFMPEG_MERGE_DLNA_LIBASS_H
#define FFMPEG_MERGE_DLNA_LIBASS_H

#include <cstdint>

// Opaque libass handles (real layouts live in libass's headers).
struct DlnaAssApi {
  void *library = nullptr;   // ASS_Library*
  void *renderer = nullptr;  // ASS_Renderer*
  void *track = nullptr;     // ASS_Track*
  void *handle = nullptr;    // dlopen handle
  bool ok = false;

  DlnaAssApi() = default;
  // Non-copyable: owns libass objects.
  DlnaAssApi(const DlnaAssApi &) = delete;
  DlnaAssApi &operator=(const DlnaAssApi &) = delete;

  // Tries dlopen candidates in order and resolves the API. Returns false
  // when no usable libass exists on this system (caller falls back).
  bool load();
  void unload();

  // Initializes library + renderer + track from subtitle text (SRT or ASS),
  // sized to [w]x[h]. Returns false when libass is missing or init fails.
  bool open(const char *subtitleText, int w, int h, int defaultFontKind);
  void close();

  // Composites the subtitles active at [ptsMs] onto the YUV420P frame
  // (data/linesize per plane). No-op unless open() succeeded.
  void render(int ptsMs, uint8_t *const data[8], const int linesize[8],
              int width, int height);
};

#endif
