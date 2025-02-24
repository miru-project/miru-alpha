#include <iostream>
#include <cstdlib>
extern "C" {
    #include "libavcodec/avcodec.h"
    #include "libavformat/avformat.h"
    #include "libavutil/avutil.h"
}
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
EXPORT int start(int input_file_num, char *files[]);
// Global contexts and streams
static AVFormatContext *input_ctx = nullptr;
static AVFormatContext *output_ctx = nullptr;
static AVStream *input_video_stream = nullptr;
static AVStream *output_video_stream = nullptr;
static AVStream *input_audio_stream = nullptr;
static AVStream *output_audio_stream = nullptr;

void check_error(int ret, const char *msg) {
    if (ret < 0) {
        char error[AV_ERROR_MAX_STRING_SIZE];
        av_strerror(ret, error, AV_ERROR_MAX_STRING_SIZE);
        std::cerr << msg << ": " << error << std::endl;
        exit(EXIT_FAILURE);
    }
}

void setup_output_video_stream() {
    // Copy codec parameters for video
    output_video_stream = avformat_new_stream(output_ctx, nullptr);
    if (!output_video_stream) {
        std::cerr << "Failed to create output video stream" << std::endl;
        exit(EXIT_FAILURE);
    }

    int ret = avcodec_parameters_copy(output_video_stream->codecpar,
                                    input_video_stream->codecpar);
    check_error(ret, "Failed to copy video codec parameters");

    // Set stream parameters for video
    output_video_stream->time_base = input_video_stream->time_base;
    output_video_stream->codecpar->codec_tag = 0;
}
void setup_output_audio_stream() {
    // Check if input audio stream exists before setting up output audio stream
    if (!input_audio_stream) {
        return; // No input audio stream, so don't set up output audio stream
    }
    // Copy codec parameters for audio
    output_audio_stream = avformat_new_stream(output_ctx, nullptr);
    if (!output_audio_stream) {
        std::cerr << "Failed to create output audio stream" << std::endl;
        exit(EXIT_FAILURE);
    }

    int ret = avcodec_parameters_copy(output_audio_stream->codecpar,
                                    input_audio_stream->codecpar);
    check_error(ret, "Failed to copy audio codec parameters");

    // Set stream parameters for audio
    output_audio_stream->time_base = input_audio_stream->time_base;
    output_audio_stream->codecpar->codec_tag = 0;
}


int64_t get_video_start_time(AVFormatContext* ctx, int video_stream_idx) {
    if (ctx->streams[video_stream_idx]->start_time != AV_NOPTS_VALUE) {
        return ctx->streams[video_stream_idx]->start_time;
    }
    return 0;
}
int64_t get_audio_start_time(AVFormatContext* ctx, int audio_stream_idx) {
    if (ctx->streams[audio_stream_idx]->start_time != AV_NOPTS_VALUE) {
        return ctx->streams[audio_stream_idx]->start_time;
    }
    return 0;
}


// Replace the existing process_packets function with this updated version
void process_packets(int64_t &last_pts_video, int64_t &last_dts_video, int64_t &last_pts_audio, int64_t &last_dts_audio) {
    AVPacket packet;
    int64_t video_start_time = 0;
    if(input_video_stream)
        video_start_time = get_video_start_time(input_ctx, input_video_stream->index);
    int64_t audio_start_time = 0;
     if(input_audio_stream)
        audio_start_time = get_audio_start_time(input_ctx, input_audio_stream->index);

    AVRational input_video_time_base;
    AVRational output_video_time_base;
    if(input_video_stream && output_video_stream){
        input_video_time_base = input_video_stream->time_base;
        output_video_time_base = output_video_stream->time_base;
    }
     AVRational input_audio_time_base;
    AVRational output_audio_time_base;
    if(input_audio_stream && output_audio_stream){
        input_audio_time_base = input_audio_stream->time_base;
        output_audio_time_base = output_audio_stream->time_base;
    }


    while (av_read_frame(input_ctx, &packet) >= 0) {
        if (input_video_stream && packet.stream_index == input_video_stream->index) {
            // Adjust timestamps for video relative to start_time
            if (packet.pts != AV_NOPTS_VALUE) {
                packet.pts -= video_start_time;
                // Convert to output timebase and add last_pts_video
                packet.pts = av_rescale_q_rnd(packet.pts,
                                            input_video_time_base,
                                            output_video_time_base,
                                            static_cast<AVRounding>(AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
                packet.pts += last_pts_video;
            }

            if (packet.dts != AV_NOPTS_VALUE) {
                packet.dts -= video_start_time;
                // Convert to output timebase and add last_dts_video
                packet.dts = av_rescale_q_rnd(packet.dts,
                                            input_video_time_base,
                                            output_video_time_base,
                                            static_cast<AVRounding>(AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
                packet.dts += last_dts_video;
            }

            packet.stream_index = output_video_stream->index;
            int ret = av_interleaved_write_frame(output_ctx, &packet);
            check_error(ret, "Error writing video packet");
        } else if (input_audio_stream && packet.stream_index == input_audio_stream->index) {
            // Adjust timestamps for audio relative to start_time
            if (packet.pts != AV_NOPTS_VALUE) {
                packet.pts -= audio_start_time;
                // Convert to output timebase and add last_pts_audio
                packet.pts = av_rescale_q_rnd(packet.pts,
                                            input_audio_time_base,
                                            output_audio_time_base,
                                            static_cast<AVRounding>(AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
                packet.pts += last_pts_audio;
            }

            if (packet.dts != AV_NOPTS_VALUE) {
                packet.dts -= audio_start_time;
                // Convert to output timebase and add last_dts_audio
                packet.dts = av_rescale_q_rnd(packet.dts,
                                            input_audio_time_base,
                                            output_audio_time_base,
                                            static_cast<AVRounding>(AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
                packet.dts += last_dts_audio;
            }
            packet.stream_index = output_audio_stream->index;
            int ret = av_interleaved_write_frame(output_ctx, &packet);
            check_error(ret, "Error writing audio packet");
        }
        av_packet_unref(&packet);
    }

    // Update last_pts and last_dts for the next file, for video
    if (input_video_stream && output_video_stream){
        if (last_pts_video == 0) {
            // For the first file, get the duration in output timebase
            last_pts_video = av_rescale_q_rnd(input_ctx->duration,
                                       AV_TIME_BASE_Q,
                                       output_video_stream->time_base,
                                       static_cast<AVRounding>(AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
            last_dts_video = last_pts_video;
        } else {
            // For subsequent files, add the duration of the current file
            int64_t duration = av_rescale_q_rnd(input_ctx->duration,
                                               AV_TIME_BASE_Q,
                                               output_video_stream->time_base,
                                               static_cast<AVRounding>(AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
            last_pts_video += duration;
            last_dts_video += duration;
        }
    }
    // Update last_pts and last_dts for the next file, for audio
     if (input_audio_stream && output_audio_stream){
        if (last_pts_audio == 0) {
            // For the first file, get the duration in output timebase
            last_pts_audio = av_rescale_q_rnd(input_ctx->duration,
                                       AV_TIME_BASE_Q,
                                       output_audio_stream->time_base,
                                       static_cast<AVRounding>(AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
            last_dts_audio = last_pts_audio;
        } else {
            // For subsequent files, add the duration of the current file
            int64_t duration = av_rescale_q_rnd(input_ctx->duration,
                                               AV_TIME_BASE_Q,
                                               output_audio_stream->time_base,
                                               static_cast<AVRounding>(AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
            last_pts_audio += duration;
            last_dts_audio += duration;
        }
    }
}

int main(int argc, char *argv[]) {
    std::cout<< "output" << argv[1] << std::endl;

    for (unsigned int  i = 2; i < argc; i++) {
        std::cout<< "input" << argv[i] << std::endl;
    }
    if (argc < 3) {
        std::cerr << "Usage: " << argv[0] << " output.mp4 input1.ts [input2.ts ...]" << std::endl;
        return EXIT_FAILURE;
    }

    const char *output_file = argv[1];
    int ret;

    // Create output context
    ret = avformat_alloc_output_context2(&output_ctx, nullptr, nullptr, output_file);
    check_error(ret, "Could not create output context");

    // Process first input to setup format
    ret = avformat_open_input(&input_ctx, argv[2], nullptr, nullptr);
    check_error(ret, "Could not open first input");

    ret = avformat_find_stream_info(input_ctx, nullptr);
    check_error(ret, "Could not find stream info");

    // Find video stream
    for (unsigned int i = 0; i < input_ctx->nb_streams; i++) {
        if (input_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            input_video_stream = input_ctx->streams[i];
            break;
        }
    }
     // Find audio stream
    for (unsigned int i = 0; i < input_ctx->nb_streams; i++) {
        if (input_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
            input_audio_stream = input_ctx->streams[i];
            break;
        }
    }


    if (!input_video_stream && !input_audio_stream) {
        std::cerr << "No video or audio stream found in the first input file" << std::endl;
        return EXIT_FAILURE;
    }

    if(input_video_stream) setup_output_video_stream();
    if(input_audio_stream) setup_output_audio_stream();


    // Open output file
    ret = avio_open(&output_ctx->pb, output_file, AVIO_FLAG_WRITE);
    check_error(ret, "Could not open output file");

    ret = avformat_write_header(output_ctx, nullptr);
    check_error(ret, "Error writing header");

    // Process all input files
    int64_t last_pts_video = 0, last_dts_video = 0;
    int64_t last_pts_audio = 0, last_dts_audio = 0;

    for (unsigned int  i = 2; i < argc; i++) {
        if (i > 2) {
            avformat_close_input(&input_ctx);
            ret = avformat_open_input(&input_ctx, argv[i], nullptr, nullptr);
            check_error(ret, "Could not open input file");

            ret = avformat_find_stream_info(input_ctx, nullptr);
            check_error(ret, "Could not find stream info");

            // Find video stream in new input
            input_video_stream = nullptr;
            for (unsigned int s = 0; s < input_ctx->nb_streams; s++) {
                if (input_ctx->streams[s]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
                    input_video_stream = input_ctx->streams[s];
                    std::cout << "Found video stream in file " << argv[i] << " at index " << s << std::endl;
                    break;
                }
            }
             // Find audio stream in new input
            input_audio_stream = nullptr;
            for (unsigned int s = 0; s < input_ctx->nb_streams; s++) {
                if (input_ctx->streams[s]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
                    input_audio_stream = input_ctx->streams[s];
                    std::cout << "Found audio stream in file " << argv[i] << " at index " << s << std::endl;
                    break;
                }
            }


        }

        std::cout << "Processing file: " << argv[i] << std::endl;
        process_packets(last_pts_video, last_dts_video, last_pts_audio, last_dts_audio);
    }

    // Write trailer and cleanup
    av_write_trailer(output_ctx);
    avio_closep(&output_ctx->pb);

    avformat_close_input(&input_ctx);
    avformat_free_context(output_ctx);

    return 0;
}
int start(int input_file_num, char *files[]) {
    //add an empty string to the beginning of the array to match the main function

    
    char** new_argv = new char*[input_file_num + 1];
    
    new_argv[0] = new char[1];
    new_argv[0][0] = '\0';
    
    for (int i = 0; i < input_file_num; i++) {
        new_argv[i + 1] = files[i];
    }
    
    main(input_file_num + 1 , new_argv);
    
    delete[] new_argv[0];
    delete[] new_argv;
    return EXIT_SUCCESS;
}