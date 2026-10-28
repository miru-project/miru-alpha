// DLNA streaming engine — C ABI surfaced to Dart through FFI.
//
// One context remuxes a single source (an already-proxied
// http://127.0.0.1:3000/proxy/... URL or a local file) into MPEG-TS written
// into an in-memory FIFO; Dart pumps the bytes to the DLNA renderer over
// HTTP. All calls for one context must come from the same isolate/thread.
//
// Two video paths:
// - remux (videoFilter == NULL): stream-copy packets — any source → TS.
// - transcode (videoFilter set): decode → libavfilter graph (subtitle burn,
//   e.g. a drawtext chain, or the ass/subtitles filter when the build ships
//   libass) → libx264 → mux; audio is always stream-copied.
#ifndef FFMPEG_MERGE_DLNA_STREAM_H
#define FFMPEG_MERGE_DLNA_STREAM_H

#ifdef _WIN32
#define DLNA_EXPORT extern "C" __declspec(dllexport)
#else
#define DLNA_EXPORT                                                            \
  extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

struct dlna_stream;

// Opens [url], seeks to [startSec] (>0.5), and prepares an mpegts muxer.
// [prebufferBytes] is how much TS the engine buffers before the first pump
// returns (~1-2 HLS segments so the renderer starts on a full buffer; capped
// at 10 s wall-time). [videoFilter] (nullable) switches to the transcode
// path with the given libavfilter graph applied to the video. [httpHeaders]
// (nullable) is a "\r\n"-joined "Key: Value" list applied to every HTTP
// request the engine makes (Referer/User-Agent/Cookie requirements of the
// source's extension). Reports the detected first video/audio decoder names
// into 32-byte buffers. 0 on success, <0 FFmpeg error.
DLNA_EXPORT int dlna_stream_open(const char *url, double startSec,
                                 int prebufferBytes, const char *videoFilter,
                                 const char *assSubtitle,
                                 const char *httpHeaders, char *videoCodec,
                                 char *audioCodec, dlna_stream **outStream);

// Next MPEG-TS bytes into [buf] (up to [cap]). Returns bytes (>0; always a
// multiple of 188 while packets remain), 0 = source ended, <0 = error
// (AVERROR(EAGAIN) = no full packet buffered yet). The first call blocks
// until the prebuffer is filled or 10 s elapsed.
DLNA_EXPORT int dlna_stream_pump(dlna_stream *s, unsigned char *buf, int cap);

// Seeks the input and restarts the muxer: the next pump emits a fresh
// PAT/PMT with a timeline from ~0 (the renderer is always re-pushed by the
// caller after a seek — TS has no byte-accurate seek). 0 ok, <0 error.
DLNA_EXPORT int dlna_stream_seek(dlna_stream *s, double sec);

// Playback position in seconds: [startSec] (+ seek target) plus the media
// time muxed so far. Advisory — feeds the sync loop and the UI.
DLNA_EXPORT double dlna_stream_position(dlna_stream *s);

// Frees the context. Safe with a partial setup.
DLNA_EXPORT void dlna_stream_close(dlna_stream *s);

#endif
