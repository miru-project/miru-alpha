/* This file was automatically generated.  Do not edit! */
#undef INTERFACE
void process_packets(int64_t&last_pts_video,int64_t&last_dts_video,int64_t&last_pts_audio,int64_t&last_dts_audio);
int64_t get_audio_start_time(AVFormatContext *ctx,int audio_stream_idx);
int64_t get_video_start_time(AVFormatContext *ctx,int video_stream_idx);
void setup_output_audio_stream();
void setup_output_video_stream();
void check_error(int ret,const char *msg);
int start(int input_file_num,char *files[]);
int start(int input_file_num,char *files[]);
#define EXPORT
