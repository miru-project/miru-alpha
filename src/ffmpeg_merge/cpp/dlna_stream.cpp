// DLNA streaming engine: remuxes (or transcodes — subtitle burn) one source
// (HLS/direct URL already routed through the miru-core /proxy/ gateway) into
// fragmented MP4 written into an in-memory FIFO that Dart pumps to the
// renderer over HTTP. Context-based — unlike the merge path there is no
// shared global state, but all calls for one context must come from the same
// isolate.
#include <algorithm>
#include <condition_variable>
#include <cstdint>
#include <cstdio>
#include <deque>
#include <mutex>
#include <new>
#include <string>
#include <thread>
#include <unistd.h>

extern "C" {
#include "libavfilter/avfilter.h"
#include "libavfilter/buffersink.h"
#include "libavfilter/buffersrc.h"
#include "libavutil/opt.h"
#include "libavutil/time.h"
}

#include "common.h"
#include "dlna_libass.h"
#include "dlna_stream.h"

#ifdef __GLIBC__
#include <malloc.h>

// Returns freed arena memory to the OS after engine teardowns. Without this
// glibc keeps freed ffmpeg contexts at the process high-water mark, which
// reads as a leak across repeated seek rebuilds.
static void release_freed_memory() { malloc_trim(0); }
#else
static void release_freed_memory() {}
#endif

// Session-thread commands (file scope: used by the session state and the
// exported wrappers).
enum {
  kCmdNone = 0,
  kCmdOpen,
  kCmdPump,
  kCmdSeek,
  kCmdClose,
};

struct dlna_stream {
  AVFormatContext *in = nullptr;
  AVFormatContext *out = nullptr;
  AVIOContext *avio = nullptr;
  unsigned char *avioBuf = nullptr;
  int inVideo = -1;
  int inAudio = -1;
  int outVideo = -1;
  int outAudio = -1;
  bool eof = false;
  bool primed = false;
  int64_t prebuffer = 0;
  // libass-direct burn: when set, decoded frames get subtitles composited
  // in-engine (no filter graph) before the encoder.
  DlnaAssApi ass;
  bool assBurn = false;
  std::string assData;
  // Playback position reporting: the timeline origin (open seek target or
  // the latest dlna_stream_seek) plus the media time muxed so far.
  int64_t startUs = 0;
  int64_t mediaUs = 0;
  // Transcode path (subtitle burn): decode → filter graph → libx264.
  bool transcode = false;
  std::string videoFilter;
  AVCodecContext *vdecCtx = nullptr;
  AVFilterGraph *graph = nullptr;
  AVFilterContext *srcCtx = nullptr;
  AVFilterContext *sinkCtx = nullptr;
  AVCodecContext *vencCtx = nullptr;
  int64_t frameCount = 0;
  // Shared rebase offset: the first DTS among the kept streams (in
  // AV_TIME_BASE units). Every stream shifts by the SAME delta so A/V stay
  // aligned after open and after each seek. In transcode mode the video
  // base comes from the first DECODED frame's timestamp.
  bool baseLocked = false;
  bool haveVideoBase = false;
  bool haveAudioBase = false;
  int64_t videoBase = AV_NOPTS_VALUE;
  int64_t audioBase = AV_NOPTS_VALUE;
  int64_t baseCommon = AV_NOPTS_VALUE;
  // Packets held until the rebase base is locked (both streams seen).
  std::deque<AVPacket *> pending;
  // Decoded frames held until the base is locked (transcode mode).
  std::deque<AVFrame *> pendingFrames;
  // Muxed MPEG-TS bytes awaiting the Dart pump.
  std::deque<uint8_t> ring;

  // --- session thread ---------------------------------------------------
  // The whole session runs on a thread THIS context owns. The Dart worker
  // isolate's thread is a VM mutator: the sampling profiler SIGPROFs it and
  // every blocking network syscall in the engine (remote TLS handshakes
  // especially) fails with EINTR — the open's 3-retry loop loses that race
  // against remote hosts. A pthread created here is never registered with
  // the VM, so it is never signaled (the same reason mdk's own threads
  // fetch the same URLs fine). Dart calls marshal onto this thread through
  // the command handshake below; the isolate's calls stay serialized.
  std::thread thread;
  std::mutex mu;
  std::condition_variable cmdCv;  // wakes the session thread
  std::condition_variable doneCv; // wakes the Dart caller
  int pendingCmd = kCmdNone;
  bool cmdDone = true;
  bool threadAlive = true;
  // Command args/results (handed over under [mu] around each handshake).
  std::string openUrl, openFilter, openAss, openHttpHeaders;
  double openStartSec = 0;
  int openPrebuffer = 0;
  char *videoCodecOut = nullptr;
  char *audioCodecOut = nullptr;
  int openRc = 0;
  unsigned char *pumpBuf = nullptr;
  int pumpCap = 0;
  int pumpResult = 0;
  double seekSec = 0;
  int seekRc = 0;
};

static std::once_flag g_stream_network_init;

static int session_open_core(dlna_stream *s);
static int session_pump_core(dlna_stream *s);
static int session_seek_core(dlna_stream *s);
static void session_close_core(dlna_stream *s);

// Hands [cmd] to the session thread and waits for it to finish. No-op when
// the thread already exited (an unexpected crash inside a command leaves
// the caller with the recorded result instead of a hang).
static void session_post(dlna_stream *s, int cmd) {
  std::unique_lock<std::mutex> lk(s->mu);
  if (!s->threadAlive) return;
  s->pendingCmd = cmd;
  s->cmdDone = false;
  lk.unlock();
  s->cmdCv.notify_one();
  lk.lock();
  s->doneCv.wait(lk, [&s] { return s->cmdDone; });
}

// The session thread: owns the ffmpeg contexts for its whole life. No Dart
// code runs here and the VM never signals this thread, so blocking network
// syscalls are EINTR-free.
static void session_thread_main(dlna_stream *s) {
  std::unique_lock<std::mutex> lk(s->mu);
  while (true) {
    s->cmdCv.wait(lk, [&s] { return s->pendingCmd != kCmdNone; });
    const int cmd = s->pendingCmd;
    s->pendingCmd = kCmdNone;
    try {
      switch (cmd) {
        case kCmdOpen:
          s->openRc = session_open_core(s);
          break;
        case kCmdPump:
          s->pumpResult = session_pump_core(s);
          break;
        case kCmdSeek:
          s->seekRc = session_seek_core(s);
          break;
        case kCmdClose:
          s->cmdDone = true;
          lk.unlock();
          s->doneCv.notify_all();
          session_close_core(s);
          return;
        default:
          break;
      }
    } catch (...) {
      // A command must never kill the thread silently: surface it as the
      // command's error result.
      if (cmd == kCmdOpen) s->openRc = AVERROR_EXTERNAL;
      if (cmd == kCmdPump) s->pumpResult = AVERROR_EXTERNAL;
      if (cmd == kCmdSeek) s->seekRc = AVERROR_EXTERNAL;
    }
    s->cmdDone = true;
    lk.unlock();
    s->doneCv.notify_all();
    lk.lock();
  }
}

static size_t ring_size(const dlna_stream *s) { return s->ring.size(); }

static int avio_write_callback(void *opaque, const uint8_t *buf, int n) {
  auto *s = static_cast<dlna_stream *>(opaque);
  s->ring.insert(s->ring.end(), buf, buf + n);
  return n;
}

static int64_t ts_to_common(const AVStream *st, int64_t ts) {
  if (ts == AV_NOPTS_VALUE) return AV_NOPTS_VALUE;
  return av_rescale_q(ts, st->time_base, AV_TIME_BASE_Q);
}

static int64_t rebase(int64_t ts, int64_t shift) {
  ts -= shift;
  return ts < 0 ? 0 : ts;
}

static int write_shifted(dlna_stream *s, AVPacket *pkt, const AVStream *ist,
                         AVStream *ost) {
  // write_header has re-set ost->time_base to the muxer's: packets must be
  // rescaled from the input timebase first, then shifted by the shared
  // rebase offset (also in ost->time_base units).
  const int64_t shift =
      av_rescale_q(s->baseCommon, AV_TIME_BASE_Q, ost->time_base);
  if (pkt->pts != AV_NOPTS_VALUE) {
    pkt->pts = rebase(
        av_rescale_q(pkt->pts, ist->time_base, ost->time_base), shift);
  }
  if (pkt->dts != AV_NOPTS_VALUE) {
    pkt->dts = rebase(
        av_rescale_q(pkt->dts, ist->time_base, ost->time_base), shift);
    if (ost == s->out->streams[s->outVideo] || s->outVideo < 0) {
      const int64_t us =
          av_rescale_q(pkt->dts, ost->time_base, AVRational{1, 1000000});
      if (us > s->mediaUs) s->mediaUs = us;
    }
  }
  if (pkt->duration > 0) {
    pkt->duration =
        av_rescale_q(pkt->duration, ist->time_base, ost->time_base);
  }
  pkt->stream_index = ost->index;
  pkt->pos = -1;
  int ret = av_interleaved_write_frame(s->out, pkt);
  av_packet_unref(pkt);
  return check_error(ret, "write packet");
}

static int flush_pending(dlna_stream *s) {
  while (!s->pending.empty()) {
    AVPacket *p = s->pending.front();
    s->pending.pop_front();
    const AVStream *ist = s->in->streams[p->stream_index];
    AVStream *ost = p->stream_index == s->inVideo
                        ? s->out->streams[s->outVideo]
                        : s->out->streams[s->outAudio];
    int ret = write_shifted(s, p, ist, ost);
    av_packet_free(&p);
    if (ret < 0) return ret;
  }
  return 0;
}

// Locks the shared rebase offset once every kept stream has reported its
// first timestamp. Returns true when the base is usable.
static bool try_lock_base(dlna_stream *s) {
  if (s->baseLocked) return true;
  const bool all = (s->outVideo < 0 || s->haveVideoBase) &&
                   (s->outAudio < 0 || s->haveAudioBase);
  if (!all && s->pending.size() + s->pendingFrames.size() < 512) return false;
  int64_t base = AV_NOPTS_VALUE;
  if (s->haveVideoBase) base = s->videoBase;
  if (s->haveAudioBase && (base == AV_NOPTS_VALUE || s->audioBase < base)) {
    base = s->audioBase;
  }
  s->baseCommon = base == AV_NOPTS_VALUE ? 0 : base;
  s->baseLocked = true;
  return true;
}

// Routes one demuxed packet into the output muxer, holding packets until the
// rebase base is locked (first DTS of every kept stream seen, or the hold
// queue overflows). Consumes [pkt] either way.
static int mux_packet(dlna_stream *s, AVPacket *pkt) {
  if (pkt->stream_index != s->inVideo && pkt->stream_index != s->inAudio) {
    av_packet_unref(pkt);
    return 0;
  }
  const bool isVideo = pkt->stream_index == s->inVideo;
  const AVStream *ist = s->in->streams[pkt->stream_index];
  if (!s->baseLocked) {
    AVPacket *held = av_packet_alloc();
    if (!held) {
      av_packet_unref(pkt);
      return AVERROR(ENOMEM);
    }
    av_packet_ref(held, pkt);
    av_packet_unref(pkt);
    if (isVideo && !s->haveVideoBase && held->dts != AV_NOPTS_VALUE) {
      s->videoBase = ts_to_common(ist, held->dts);
      s->haveVideoBase = true;
    } else if (!isVideo && !s->haveAudioBase && held->dts != AV_NOPTS_VALUE) {
      s->audioBase = ts_to_common(ist, held->dts);
      s->haveAudioBase = true;
    }
    s->pending.push_back(held);
    if (!try_lock_base(s)) return 0;
    return flush_pending(s);
  }
  AVStream *ost =
      isVideo ? s->out->streams[s->outVideo] : s->out->streams[s->outAudio];
  return write_shifted(s, pkt, ist, ost);
}

// --- transcode path (subtitle burn): decode → filter → encode -------------

static int write_encoded(dlna_stream *s, AVPacket *enc) {
  AVStream *ost = s->out->streams[s->outVideo];
  const int64_t shift =
      av_rescale_q(s->baseCommon, AV_TIME_BASE_Q, ost->time_base);
  av_packet_rescale_ts(enc, s->vencCtx->time_base, ost->time_base);
  if (enc->pts != AV_NOPTS_VALUE) {
    enc->pts = rebase(enc->pts, shift);
  }
  if (enc->dts != AV_NOPTS_VALUE) {
    enc->dts = rebase(enc->dts, shift);
    const int64_t us =
        av_rescale_q(enc->dts, ost->time_base, AVRational{1, 1000000});
    if (us > s->mediaUs) s->mediaUs = us;
  }
  const int ret = av_interleaved_write_frame(s->out, enc);
  av_packet_free(&enc);
  return check_error(ret, "write encoded");
}

// Sends one frame to the video encoder and drains all resulting packets.
// Consumes [frame]. Callers rescale pts to the encoder time base first.
static int encode_frame(dlna_stream *s, AVFrame *frame) {
  int ret = avcodec_send_frame(s->vencCtx, frame);
  av_frame_free(&frame);
  if (ret < 0) return check_error(ret, "encode send");
  while (true) {
    AVPacket *enc = av_packet_alloc();
    ret = avcodec_receive_packet(s->vencCtx, enc);
    if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
      av_packet_free(&enc);
      break;
    }
    if (ret < 0) {
      av_packet_free(&enc);
      return check_error(ret, "encode receive");
    }
    ret = write_encoded(s, enc);
    if (ret < 0) return ret;
  }
  return 0;
}

// Pushes a decoded frame through the filter graph and drains the encoder.
// Consumes [frame].
static int filter_encode_frame(dlna_stream *s, AVFrame *frame) {
  if (s->assBurn) {
    // libass-direct burn: composite the subtitle onto the decoded frame at
    // the original media PTS, then encode — no filter graph needed.
    // Consumes [frame].
    AVStream *vs = s->in->streams[s->inVideo];
    int64_t ts = frame->best_effort_timestamp != AV_NOPTS_VALUE
                     ? frame->best_effort_timestamp
                     : frame->pts;
    if (ts != AV_NOPTS_VALUE) {
      const int64_t ms =
          av_rescale_q(ts, vs->time_base, AV_TIME_BASE_Q) / 1000;
      s->ass.render(static_cast<int>(ms), frame->data, frame->linesize,
                    frame->width, frame->height);
    }
    frame->pts = av_rescale_q(frame->pts, vs->time_base,
                              s->vencCtx->time_base);
    return encode_frame(s, frame);
  }
  int ret = av_buffersrc_add_frame_flags(s->srcCtx, frame,
                                         AV_BUFFERSRC_FLAG_KEEP_REF);
  av_frame_free(&frame);
  if (ret < 0) return check_error(ret, "buffersrc");
  while (true) {
    AVFrame *filtered = av_frame_alloc();
    ret = av_buffersink_get_frame(s->sinkCtx, filtered);
    if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
      av_frame_free(&filtered);
      break;
    }
    if (ret < 0) {
      av_frame_free(&filtered);
      return check_error(ret, "buffersink");
    }
    filtered->pts = av_rescale_q(filtered->pts,
                                 av_buffersink_get_time_base(s->sinkCtx),
                                 s->vencCtx->time_base);
    ret = encode_frame(s, filtered);
    if (ret < 0) return ret;
  }
  return 0;
}

// Decodes one video packet and feeds the frames through the filter/encode
// path. Consumes [pkt].
static int transcode_packet(dlna_stream *s, AVPacket *pkt) {
  int ret = avcodec_send_packet(s->vdecCtx, pkt);
  av_packet_unref(pkt);
  if (ret < 0 && ret != AVERROR(EAGAIN)) {
    return check_error(ret, "decode send");
  }
  while (true) {
    AVFrame *frame = av_frame_alloc();
    ret = avcodec_receive_frame(s->vdecCtx, frame);
    if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
      av_frame_free(&frame);
      break;
    }
    if (ret < 0) {
      av_frame_free(&frame);
      return check_error(ret, "decode receive");
    }
    if (!s->baseLocked) {
      if (!s->haveVideoBase &&
          frame->best_effort_timestamp != AV_NOPTS_VALUE) {
        s->videoBase = av_rescale_q(
            frame->best_effort_timestamp,
            s->in->streams[s->inVideo]->time_base, AV_TIME_BASE_Q);
        s->haveVideoBase = true;
      }
      s->pendingFrames.push_back(frame);
      if (!try_lock_base(s)) continue;
      // Base locked: flush held packets, then held frames.
      int r = flush_pending(s);
      if (r < 0) {
        av_frame_free(&frame);
        return r;
      }
      while (!s->pendingFrames.empty()) {
        AVFrame *f = s->pendingFrames.front();
        s->pendingFrames.pop_front();
        r = filter_encode_frame(s, f);
        if (r < 0) return r;
      }
      continue;
    }
    ret = filter_encode_frame(s, frame);
    if (ret < 0) return ret;
  }
  return 0;
}

static int setup_transcode(dlna_stream *s) {
  AVStream *vs = s->in->streams[s->inVideo];
  const AVCodec *dec = avcodec_find_decoder(vs->codecpar->codec_id);
  if (!dec) return AVERROR_DECODER_NOT_FOUND;
  s->vdecCtx = avcodec_alloc_context3(dec);
  if (!s->vdecCtx) return AVERROR(ENOMEM);
  int ret = avcodec_parameters_to_context(s->vdecCtx, vs->codecpar);
  if (ret < 0) return check_error(ret, "decoder params");
  s->vdecCtx->pkt_timebase = vs->time_base;
  ret = avcodec_open2(s->vdecCtx, dec, nullptr);
  if (ret < 0) return check_error(ret, "decoder open");

  AVRational fr = av_guess_frame_rate(s->in, vs, nullptr);
  if (fr.num <= 0 || fr.den <= 0) fr = AVRational{25, 1};
  AVRational sar = vs->codecpar->sample_aspect_ratio;
  if (sar.num <= 0 || sar.den <= 0) sar = AVRational{1, 1};

  s->graph = nullptr;
  s->srcCtx = s->sinkCtx = nullptr;
  if (s->assBurn) {
    // libass-direct: subtitle text (SRT or ASS) is composited in-engine.
    int fontKind = 0;
    if (access("/system/fonts", R_OK) == 0) {
      fontKind = 1;
    }
    if (!s->ass.open(s->assData.c_str(), s->vdecCtx->width,
                     s->vdecCtx->height, fontKind)) {
      s->assBurn = false;
      s->ass.close();
    }
  } else {
    s->graph = avfilter_graph_alloc();
    if (!s->graph) return AVERROR(ENOMEM);
  char args[512];
  snprintf(args, sizeof(args),
           "video_size=%dx%d:pix_fmt=%d:time_base=%d/%d:pixel_aspect=%d/%d:"
           "frame_rate=%d/%d",
           s->vdecCtx->width, s->vdecCtx->height, s->vdecCtx->pix_fmt,
           vs->time_base.num, vs->time_base.den, sar.num, sar.den, fr.num,
           fr.den);
  const AVFilter *buffer = avfilter_get_by_name("buffer");
  const AVFilter *buffersink = avfilter_get_by_name("buffersink");
  if (!buffer || !buffersink) return AVERROR_FILTER_NOT_FOUND;
  ret = avfilter_graph_create_filter(&s->srcCtx, buffer, "src", args, nullptr,
                                     s->graph);
  if (ret < 0) return check_error(ret, "buffersrc create");
  ret = avfilter_graph_create_filter(&s->sinkCtx, buffersink, "sink", nullptr,
                                     nullptr, s->graph);
  if (ret < 0) return check_error(ret, "buffersink create");
  const enum AVPixelFormat outPix = AV_PIX_FMT_YUV420P;
  ret = av_opt_set_bin(s->sinkCtx, "pix_fmts",
                       reinterpret_cast<const uint8_t *>(&outPix),
                       sizeof(outPix), AV_OPT_SEARCH_CHILDREN);
  if (ret < 0) return check_error(ret, "buffersink pix_fmts");

  AVFilterInOut *graphOut = avfilter_inout_alloc();
  AVFilterInOut *graphIn = avfilter_inout_alloc();
  if (!graphOut || !graphIn) return AVERROR(ENOMEM);
  graphOut->name = av_strdup("in");
  graphOut->filter_ctx = s->srcCtx;
  graphOut->pad_idx = 0;
  graphOut->next = nullptr;
  graphIn->name = av_strdup("out");
  graphIn->filter_ctx = s->sinkCtx;
  graphIn->pad_idx = 0;
  graphIn->next = nullptr;
  ret = avfilter_graph_parse_ptr(s->graph, s->videoFilter.c_str(), &graphIn,
                                 &graphOut, nullptr);
  avfilter_inout_free(&graphIn);
  avfilter_inout_free(&graphOut);
  if (ret < 0) return check_error(ret, "filter graph parse");
  ret = avfilter_graph_config(s->graph, nullptr);
  if (ret < 0) return check_error(ret, "filter graph config");
  }

  const AVCodec *enc = avcodec_find_encoder_by_name("libx264");
  if (!enc) enc = avcodec_find_encoder(AV_CODEC_ID_H264);
  if (!enc) return AVERROR_ENCODER_NOT_FOUND;
  s->vencCtx = avcodec_alloc_context3(enc);
  if (!s->vencCtx) return AVERROR(ENOMEM);
  s->vencCtx->time_base = AVRational{fr.den, fr.num};
  s->vencCtx->framerate = fr;
  s->vencCtx->width = s->assBurn ? s->vdecCtx->width
                                 : av_buffersink_get_w(s->sinkCtx);
  s->vencCtx->height = s->assBurn ? s->vdecCtx->height
                                  : av_buffersink_get_h(s->sinkCtx);
  s->vencCtx->pix_fmt = AV_PIX_FMT_YUV420P;
  s->vencCtx->gop_size = 60;
  s->vencCtx->max_b_frames = 2;
  s->vencCtx->thread_count = 2;
  av_opt_set(s->vencCtx->priv_data, "preset", "veryfast", 0);
  av_opt_set(s->vencCtx->priv_data, "crf", "23", 0);
  ret = avcodec_open2(s->vencCtx, enc, nullptr);
  if (ret < 0) return check_error(ret, "encoder open");

  AVStream *os = avformat_new_stream(s->out, nullptr);
  if (!os) return AVERROR(ENOMEM);
  ret = avcodec_parameters_from_context(os->codecpar, s->vencCtx);
  if (ret < 0) return check_error(ret, "encoder stream params");
  os->time_base = s->vencCtx->time_base;
  os->codecpar->codec_tag = 0;
  s->outVideo = os->index;
  return 0;
}

static void teardown_transcode(dlna_stream *s) {
  for (AVFrame *f : s->pendingFrames) av_frame_free(&f);
  s->pendingFrames.clear();
  s->ass.close();
  s->assBurn = false;
  if (s->vencCtx) avcodec_free_context(&s->vencCtx);
  if (s->graph) avfilter_graph_free(&s->graph);
  if (s->vdecCtx) avcodec_free_context(&s->vdecCtx);
  s->graph = nullptr;
  s->srcCtx = s->sinkCtx = nullptr;
  s->vencCtx = nullptr;
  s->vdecCtx = nullptr;
}

static int setup_output(dlna_stream *s) {
  int ret =
      avformat_alloc_output_context2(&s->out, nullptr, "mpegts", nullptr);
  if (ret < 0) return check_error(ret, "alloc mpegts output");
  const int kAvioBuf = 64 * 1024;
  s->avioBuf = static_cast<unsigned char *>(av_malloc(kAvioBuf));
  if (!s->avioBuf) return AVERROR(ENOMEM);
  s->avio = avio_alloc_context(s->avioBuf, kAvioBuf, 1, s, nullptr,
                               avio_write_callback, nullptr);
  if (!s->avio) return AVERROR(ENOMEM);
  s->out->pb = s->avio;
  s->out->flags |= AVFMT_FLAG_CUSTOM_IO;
  if (s->transcode) {
    ret = setup_transcode(s);
    if (ret < 0) return ret;
  } else if (s->inVideo >= 0) {
    AVStream *os = avformat_new_stream(s->out, nullptr);
    if (!os) return AVERROR(ENOMEM);
    ret = avcodec_parameters_copy(os->codecpar,
                                  s->in->streams[s->inVideo]->codecpar);
    if (ret < 0) return check_error(ret, "copy video params");
    os->time_base = s->in->streams[s->inVideo]->time_base;
    os->codecpar->codec_tag = 0;
    s->outVideo = os->index;
  }
  if (s->inAudio >= 0) {
    AVStream *os = avformat_new_stream(s->out, nullptr);
    if (!os) return AVERROR(ENOMEM);
    ret = avcodec_parameters_copy(os->codecpar,
                                  s->in->streams[s->inAudio]->codecpar);
    if (ret < 0) return check_error(ret, "copy audio params");
    os->time_base = s->in->streams[s->inAudio]->time_base;
    os->codecpar->codec_tag = 0;
    s->outAudio = os->index;
  }
  AVDictionary *opts = nullptr;
  // Re-emit PAT/PMT on keyframes: a renderer joining mid-stream (the seek
  // re-push) decodes from the first keyframe it sees. MPEG-TS is the DLNA
  // lingua franca: it streams over a non-seekable pipe (no moov needed)
  // and every probed sink list accepts it, declared as plain
  // `video/mpeg`/`video/mp4` wildcards or spec-defined DLNA.ORG_PN TS
  // profiles. The fragmented-MP4 detour was NOT universally decodable:
  // profile-bound renderers reported PLAYING while rendering nothing.
  av_dict_set(&opts, "mpegts_flags", "resend_headers", 0);
  av_dict_set(&opts, "mpegts_copyts", "0", 0);
  ret = avformat_write_header(s->out, &opts);
  av_dict_free(&opts);
  if (ret < 0) return check_error(ret, "write mpegts header");
  return 0;
}

static void teardown_output(dlna_stream *s) {
  if (s->out) {
    if (s->outVideo >= 0 || s->outAudio >= 0) {
      // Flushes the interleaver; the trailer bytes land in the ring and are
      // discarded by the caller when the stream is torn down.
      av_write_trailer(s->out);
    }
    if (s->avio) {
      av_freep(&s->avio->buffer);
      avio_context_free(&s->avio);
    }
    s->avioBuf = nullptr;
    avformat_free_context(s->out);
    s->out = nullptr;
  }
  s->outVideo = s->outAudio = -1;
  if (s->transcode) teardown_transcode(s);
}

static void base_reset(dlna_stream *s) {
  for (AVPacket *p : s->pending) av_packet_free(&p);
  s->pending.clear();
  s->baseLocked = false;
  s->haveVideoBase = s->haveAudioBase = false;
  s->videoBase = s->audioBase = AV_NOPTS_VALUE;
  s->baseCommon = AV_NOPTS_VALUE;
  s->ring.clear();
  s->primed = false;
  s->eof = false;
  s->mediaUs = 0;
  s->frameCount = 0;
}

// Frees everything the stream owns. Never throws; safe on partial setup.
static void stream_cleanup(dlna_stream *s) {
  teardown_output(s);
  if (s->in) avformat_close_input(&s->in);
  for (AVPacket *p : s->pending) av_packet_free(&p);
  s->pending.clear();
  for (AVFrame *f : s->pendingFrames) av_frame_free(&f);
  s->pendingFrames.clear();
}

// Reads one input packet through the muxer. 0 = EOF, >0 = ok, <0 = error.
static int read_one(dlna_stream *s) {
  AVPacket *pkt = av_packet_alloc();
  if (!pkt) return AVERROR(ENOMEM);
  int ret = av_read_frame(s->in, pkt);
  if (ret < 0) {
    av_packet_free(&pkt);
    if (ret == AVERROR_EOF || avio_feof(s->in->pb)) {
      s->eof = true;
      return 0;
    }
    return check_error(ret, "read frame");
  }
  if (s->transcode && pkt->stream_index == s->inVideo) {
    ret = transcode_packet(s, pkt);  // consumes pkt
  } else {
    ret = mux_packet(s, pkt);  // consumes pkt
  }
  av_packet_free(&pkt);
  return ret < 0 ? ret : 1;
}

// Runs on the session thread: opens the source and builds the muxer from
// the open args the caller handed over.
static int session_open_core(dlna_stream *s) {
  s->prebuffer = s->openPrebuffer > 0 ? s->openPrebuffer : 0;
  s->startUs =
      s->openStartSec > 0
          ? static_cast<int64_t>(s->openStartSec * 1000000.0)
          : 0;
  if (!s->openFilter.empty()) {
    s->videoFilter = s->openFilter;
  }
  if (!s->openAss.empty()) {
    s->assData = s->openAss;
    s->assBurn = true;
  }

  AVDictionary *opts = nullptr;
  av_dict_set(&opts, "rw_timeout", "15000000", 0);
  av_dict_set(&opts, "reconnect", "1", 0);
  av_dict_set(&opts, "reconnect_streamed", "1", 0);
  av_dict_set(&opts, "reconnect_delay_max", "7", 0);
  // Extension headers (Referer/User-Agent/Cookie…): many sources refuse
  // requests without them. The http protocol applies these to the manifest
  // AND every segment/variant fetch; other demuxers ignore the option.
  if (!s->openHttpHeaders.empty()) {
    av_dict_set(&opts, "headers", s->openHttpHeaders.c_str(), 0);
  }
  // Mirror the local player's open profile (fvp sets avformat.extension_picky=0,
  // avformat.allowed_segment_extensions=ALL, strict=experimental and
  // rtsp_transport=tcp on every source) so both engines fed the same URL +
  // headers issue the same requests and accept the same manifests/segments.
  // Without it the hls demuxer's default extension pickiness rejects segments
  // the player plays (weird extensions, fMP4 init segments, no-extension URLs).
  // `safe` stays at its default on purpose: it only gates file:// children of
  // remote playlists, and the cast engine must never read local files into the
  // stream it ships to the LAN.
  av_dict_set(&opts, "extension_picky", "0", 0);
  av_dict_set(&opts, "allowed_segment_extensions", "ALL", 0);
  av_dict_set(&opts, "strict", "experimental", 0);
  av_dict_set(&opts, "rtsp_transport", "tcp", 0);
  int ret;
  for (int attempt = 1;; attempt++) {
    ret = avformat_open_input(&s->in, s->openUrl.c_str(), nullptr, &opts);
    if (ret >= 0 || attempt >= 3 || ret != AVERROR(EINTR)) break;
    check_error(ret, "stream open input (retrying)");
    avformat_close_input(&s->in);
  }
  av_dict_free(&opts);
  if (ret < 0) {
    check_error(ret, "stream open input");
    stream_cleanup(s);
    return ret;
  }
  ret = avformat_find_stream_info(s->in, nullptr);
  if (ret < 0) {
    check_error(ret, "stream find info");
    stream_cleanup(s);
    return ret;
  }
  for (unsigned i = 0; i < s->in->nb_streams; i++) {
    const AVStream *st = s->in->streams[i];
    if (st->codecpar->codec_type == AVMEDIA_TYPE_VIDEO && s->inVideo < 0) {
      s->inVideo = static_cast<int>(i);
    }
    if (st->codecpar->codec_type == AVMEDIA_TYPE_AUDIO && s->inAudio < 0) {
      s->inAudio = static_cast<int>(i);
    }
  }
  if (s->inVideo < 0 && s->inAudio < 0) {
    stream_cleanup(s);
    return AVERROR_STREAM_NOT_FOUND;
  }
  // A filter on an audio-only source is meaningless — remux instead.
  s->transcode = (!s->videoFilter.empty() || s->assBurn) && s->inVideo >= 0;
  if (s->openStartSec > 0.5) {
    // Non-fatal: a failed seek just starts from the top.
    ret = av_seek_frame(
        s->in, -1, static_cast<int64_t>(s->openStartSec * AV_TIME_BASE),
        AVSEEK_FLAG_BACKWARD);
    check_error(ret, "stream initial seek");
  }
  ret = setup_output(s);
  if (ret < 0) {
    stream_cleanup(s);
    return ret;
  }
  if (s->videoCodecOut && s->inVideo >= 0) {
    snprintf(s->videoCodecOut, 32, "%s",
             avcodec_get_name(s->in->streams[s->inVideo]->codecpar->codec_id));
  }
  if (s->audioCodecOut && s->inAudio >= 0) {
    snprintf(s->audioCodecOut, 32, "%s",
             avcodec_get_name(s->in->streams[s->inAudio]->codecpar->codec_id));
  }
  return 0;
}

DLNA_EXPORT int dlna_stream_open(const char *url, double startSec,
                                 int prebufferBytes, const char *videoFilter,
                                 const char *assSubtitle,
                                 const char *httpHeaders, char *videoCodec,
                                 char *audioCodec, dlna_stream **outStream) {
  std::call_once(g_stream_network_init, [] { avformat_network_init(); });
  if (!url || !outStream) return AVERROR(EINVAL);
  if (videoCodec) videoCodec[0] = '\0';
  if (audioCodec) audioCodec[0] = '\0';

  auto *s = new (std::nothrow) dlna_stream();
  if (!s) return AVERROR(ENOMEM);
  s->openUrl = url;
  s->openStartSec = startSec;
  s->openPrebuffer = prebufferBytes;
  if (videoFilter && videoFilter[0] != '\0') s->openFilter = videoFilter;
  if (assSubtitle && assSubtitle[0] != '\0') s->openAss = assSubtitle;
  if (httpHeaders && httpHeaders[0] != '\0') s->openHttpHeaders = httpHeaders;
  s->videoCodecOut = videoCodec;
  s->audioCodecOut = audioCodec;
  try {
    s->thread = std::thread(session_thread_main, s);
  } catch (...) {
    delete s;
    return AVERROR(ENOMEM);
  }
  session_post(s, kCmdOpen);
  const int rc = s->openRc;
  if (rc != 0) {
    // session_open_core cleaned its own partial state; stop the thread and
    // free the shell.
    session_post(s, kCmdClose);
    s->thread.join();
    delete s;
    return rc;
  }
  *outStream = s;
  return 0;
}

// Runs on the session thread.
static int session_pump_core(dlna_stream *s) {
  if (!s->primed) {
    // Buffer ~1-2 segments before the first byte reaches the renderer so it
    // starts on a full buffer; never stall longer than 10 s (slow sources
    // still start).
    const int64_t deadline = av_gettime() + 10 * 1000000LL;
    while (ring_size(s) < static_cast<size_t>(s->prebuffer) &&
           av_gettime() < deadline) {
      int r = read_one(s);
      if (r == 0) break;
      if (r < 0) return r;
    }
    s->primed = true;
  }
  // Steady state: top the ring up towards one pump's worth, then hand out
  // up to [cap] bytes. The ring stays bounded: reads happen only while it is
  // below cap.
  while (ring_size(s) < static_cast<size_t>(s->pumpCap) && !s->eof) {
    int r = read_one(s);
    if (r == 0) break;
    if (r < 0) return r;
  }
  size_t n = ring_size(s);
  if (n > static_cast<size_t>(s->pumpCap)) n = static_cast<size_t>(s->pumpCap);
  // TS packets are 188 bytes: never hand out a torn packet, even at a
  // pause boundary or a seek restart — the renderer re-syncs on packet
  // boundaries and a mid-packet cut ends its stream.
  n -= n % 188;
  if (n == 0) {
    return s->eof ? 0 : AVERROR(EAGAIN);
  }
  std::copy(s->ring.begin(), s->ring.begin() + static_cast<long>(n),
            s->pumpBuf);
  s->ring.erase(s->ring.begin(), s->ring.begin() + static_cast<long>(n));
  return static_cast<int>(n);
}

DLNA_EXPORT int dlna_stream_pump(dlna_stream *s, unsigned char *buf, int cap) {
  if (!s || !buf || cap <= 0) return AVERROR(EINVAL);
  s->pumpBuf = buf;
  s->pumpCap = cap;
  session_post(s, kCmdPump);
  return s->pumpResult;
}

// Runs on the session thread.
static int session_seek_core(dlna_stream *s) {
  const double sec = s->seekSec;
  // Tear the muxer down FIRST (its trailer bytes land in the ring), then
  // drop everything buffered; the fresh muxer the renderer re-GETs after the
  // re-push starts a clean fMP4 byte stream from ~0.
  teardown_output(s);
  base_reset(s);
  release_freed_memory();
  s->startUs = sec > 0 ? static_cast<int64_t>(sec * 1000000.0) : 0;
  int ret = av_seek_frame(
      s->in, -1, static_cast<int64_t>(sec * AV_TIME_BASE),
      AVSEEK_FLAG_BACKWARD);
  if (ret < 0) return check_error(ret, "stream seek");
  ret = setup_output(s);
  return check_error(ret, "restart muxer after seek");
}

DLNA_EXPORT int dlna_stream_seek(dlna_stream *s, double sec) {
  if (!s || !s->in) return AVERROR(EINVAL);
  s->seekSec = sec;
  session_post(s, kCmdSeek);
  return s->seekRc;
}

DLNA_EXPORT double dlna_stream_position(dlna_stream *s) {
  if (!s) return 0.0;
  return (s->startUs + s->mediaUs) / 1000000.0;
}

// Runs on the session thread: tears the session down, then the thread exits.
static void session_close_core(dlna_stream *s) {
  stream_cleanup(s);
  release_freed_memory();
}

DLNA_EXPORT void dlna_stream_close(dlna_stream *s) {
  if (!s) return;
  if (s->thread.joinable()) {
    session_post(s, kCmdClose);
    s->thread.join();
  } else {
    stream_cleanup(s);
  }
  delete s;
}

DLNA_EXPORT int dlna_has_libass() {
  DlnaAssApi probe;
  const bool ok = probe.load();
  probe.unload();
  return ok ? 1 : 0;
}
