// libass-direct implementation — see dlna_libass.h.
//
// The libass API is resolved dynamically (dlsym on POSIX, LoadLibraryA on
// Windows) against a manually mirrored ASS_Image layout (stable public ABI
// of libass), so this compiles without any libass headers on any platform.
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#else
#include <dlfcn.h>
#endif

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "dlna_libass.h"

// Mirrors libass's ASS_Image (public ABI, stable).
struct DlnaAssImage {
  int w, h;
  int stride;
  unsigned char *bitmap;
  uint32_t color;
  int dst_x, dst_y;
  DlnaAssImage *next;
};

// libass color layout (ASS convention): 0x00BBGGRR in the low bits with the
// alpha byte in bits 24-31, where 0 = opaque and 255 = transparent (the
// ASS \alpha semantics), pre-multiplied into the per-pixel bitmap coverage.
// The blending below multiplies bitmap coverage by the color alpha.
struct DlnaAssFns {
  void *(*library_init)();
  void (*library_done)(void *);
  void *(*renderer_init)(void *);
  void (*renderer_done)(void *);
  void *(*new_track)(void *);
  void (*free_track)(void *);
  void *(*read_memory)(void *, char *, size_t, const char *);
  void (*set_frame_size)(void *, int, int);
  void (*set_fonts)(void *, const char *, const char *, int, const char *,
                    int);
  void *(*render_frame)(void *, void *, long long, int *);
  void (*flush_events)(void *);
};

static DlnaAssFns fns;

bool DlnaAssApi::load() {
  if (ok) return true;
#ifdef _WIN32
  // No libass DLL ships with the bundled Windows ffmpeg build: these loads
  // normally fail and the burn path stays disabled (ok == false).
  const char *names[] = {"libass.dll", "libass-9.dll", "libass-8.dll",
                         "libass-6.dll", "libass-5.dll"};
  for (const char *name : names) {
    handle = LoadLibraryA(name);
    if (handle) break;
  }
  if (!handle) return false;
  auto sym = [&](const char *n) {
    return reinterpret_cast<void *>(
        GetProcAddress(static_cast<HMODULE>(handle), n));
  };
#else
  const char *names[] = {"libass.so.9", "libass.so.8", "libass.so.6",
                         "libass.so.5", "libass.so"};
  for (const char *name : names) {
    handle = dlopen(name, RTLD_NOW | RTLD_LOCAL);
    if (handle) break;
  }
  if (!handle) return false;
  auto sym = [&](const char *n) { return dlsym(handle, n); };
#endif
  fns.library_init = (void *(*)(void))sym("ass_library_init");
  fns.library_done = (void (*)(void *))sym("ass_library_done");
  fns.renderer_init = (void *(*)(void *))sym("ass_renderer_init");
  fns.renderer_done = (void (*)(void *))sym("ass_renderer_done");
  fns.new_track = (void *(*)(void *))sym("ass_new_track");
  fns.free_track = (void (*)(void *))sym("ass_free_track");
  fns.read_memory =
      (void *(*)(void *, char *, size_t, const char *))sym("ass_read_memory");
  fns.set_frame_size = (void (*)(void *, int, int))sym("ass_set_frame_size");
  fns.set_fonts = (void (*)(void *, const char *, const char *, int,
                            const char *, int))sym("ass_set_fonts");
  fns.render_frame =
      (void *(*)(void *, void *, long long, int *))sym("ass_render_frame");
  fns.flush_events = (void (*)(void *))sym("ass_flush_events");
  ok = fns.library_init && fns.library_done && fns.renderer_init &&
       fns.renderer_done && fns.new_track && fns.free_track &&
       fns.read_memory && fns.set_frame_size && fns.set_fonts &&
       fns.render_frame;
  return ok;
}

void DlnaAssApi::unload() {
#ifdef _WIN32
  if (handle) FreeLibrary(static_cast<HMODULE>(handle));
#else
  if (handle) dlclose(handle);
#endif
  handle = nullptr;
  ok = false;
}

bool DlnaAssApi::open(const char *subtitleText, int w, int h,
                      int defaultFontKind) {
  if (!load()) return false;
  close();
  library = fns.library_init();
  if (!library) return false;
  renderer = fns.renderer_init(library);
  if (!renderer) {
    fns.library_done(library);
    library = nullptr;
    return false;
  }
  // ass_read_memory takes ownership: libass frees the buffer itself with
  // free() (success or failure), so it must come from malloc and must
  // never be freed here.
  const size_t len = strlen(subtitleText);
  char *copy = static_cast<char *>(malloc(len + 1));
  if (!copy) return false;
  memcpy(copy, subtitleText, len + 1);
  track = fns.read_memory(library, copy, len, nullptr);
  if (!track) {
    fns.renderer_done(renderer);
    fns.library_done(library);
    renderer = nullptr;
    return false;
  }
  fns.set_frame_size(renderer, w, h);
  // defaultFontKind: 0 = no explicit font file (fontconfig/autodetect —
  // linux), 1 = android system font (no fontconfig on android; libass
  // falls back to the given default font file).
  const char *defaultFont = nullptr;
  if (defaultFontKind == 1) defaultFont = "/system/fonts/Roboto-Regular.ttf";
  // Provider 1 = AUTODETECT; libass falls back to the default font file
  // when no provider is usable (android has no fontconfig).
  fns.set_fonts(renderer, defaultFont, "sans-serif", 1, nullptr, 0);
  return true;
}

void DlnaAssApi::close() {
  if (track) fns.free_track(track);
  if (renderer) fns.renderer_done(renderer);
  if (library) fns.library_done(library);
  track = renderer = library = nullptr;
}

// BT.601 limited-range RGB→YUV (mpegts).
static inline void rgbToYuv(int r, int g, int b, int *y, int *u, int *v) {
  *y = (66 * r + 129 * g + 25 * b + 128) >> 8;
  *y += 16;
  *u = 128 + ((-38 * r - 74 * g + 112 * b + 128) >> 8);
  *v = 128 + ((112 * r - 94 * g - 18 * b + 128) >> 8);
}

void DlnaAssApi::render(int ptsMs, uint8_t *const data[8],
                        const int linesize[8], int width, int height) {
  if (!ok || !track) return;
  int change = 0;
  DlnaAssImage *img =
      static_cast<DlnaAssImage *>(fns.render_frame(renderer, track, ptsMs,
                                                   &change));
  for (; img; img = img->next) {
    if (!img->bitmap || img->w <= 0 || img->h <= 0) continue;
    // libass color layout (empirically confirmed): 0xRRGGBBAA where the
    // low byte is the ASS transparency (0 = opaque, 255 = invisible).
    // libass folds per-event alpha into the bitmap coverage; the color
    // byte scales it (e.g. \alpha tags).
    const int r = (img->color >> 24) & 0xFF;
    const int g = (img->color >> 16) & 0xFF;
    const int b = (img->color >> 8) & 0xFF;
    const int styleTransparency = img->color & 0xFF;
    const int styleAlpha = 255 - styleTransparency;
    int cy, cu, cv;
    rgbToYuv(r, g, b, &cy, &cu, &cv);

    const int x0 = img->dst_x < 0 ? 0 : img->dst_x;
    const int y0 = img->dst_y < 0 ? 0 : img->dst_y;
    const int x1 = img->dst_x + img->w > width ? width : img->dst_x + img->w;
    const int y1 = img->dst_y + img->h > height ? height
                                                : img->dst_y + img->h;
    for (int y = y0; y < y1; y++) {
      const int by = y - img->dst_y;
      const unsigned char *cov = img->bitmap + by * img->stride;
      uint8_t *yrow = data[0] + y * linesize[0];
      uint8_t *urow = data[1] + (y >> 1) * linesize[1];
      uint8_t *vrow = data[2] + (y >> 1) * linesize[2];
      for (int x = x0; x < x1; x++) {
        const int coverage = cov[x - img->dst_x];
        if (coverage == 0) continue;
        const int a =
            (coverage * styleAlpha + 127) / 255;
        if (a == 0) continue;
        const int px = x >> 1, py = y >> 1;
        uint8_t *upx = urow + px;
        uint8_t *vpx = vrow + px;
        uint8_t *ypx = yrow + x;
        // Blend luma.
        *ypx = static_cast<uint8_t>((cy * a + *ypx * (255 - a) + 127) / 255);
        // Blend chroma at half resolution: accumulate both pixels of the
        // 2x2 block for even x/y, then apply.
        const bool blockLead = ((x & 1) == 0) && ((y & 1) == 0);
        if (blockLead) {
          // Sample this pixel's alpha for the block; subs are large text so
          // the 2x2 alpha variance is small.
          const int ca = a;
          *upx = static_cast<uint8_t>((cu * ca + *upx * (255 - ca) + 127) / 255);
          *vpx = static_cast<uint8_t>((cv * ca + *vpx * (255 - ca) + 127) / 255);
        }
      }
    }
  }
}
