import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_player.freezed.dart';
part 'video_player.g.dart';

@freezed
abstract class DomainVideoPlayerState with _$DomainVideoPlayerState {
  const factory DomainVideoPlayerState({
    @Default(false) bool showSettings,
    @Default(false) bool showControls,
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(1.0) double speed,
    @Default('') String currentSubtitle,
    @Default({}) Map<String, String> qualityMap,
    @Default(0.0) double ratio,
  }) = _DomainVideoPlayerState;

  factory DomainVideoPlayerState.fromJson(Map<String, dynamic> json) =>
      _$DomainVideoPlayerStateFromJson(json);
}

@freezed
abstract class DomainVideoQuality with _$DomainVideoQuality {
  const factory DomainVideoQuality({
    required String label,
    required String url,
  }) = _DomainVideoQuality;

  factory DomainVideoQuality.fromJson(Map<String, dynamic> json) =>
      _$DomainVideoQualityFromJson(json);
}

@freezed
abstract class DomainSubtitle with _$DomainSubtitle {
  const factory DomainSubtitle({
    String? name,
    required String url,
    String? lang,
  }) = _DomainSubtitle;

  factory DomainSubtitle.fromJson(Map<String, dynamic> json) =>
      _$DomainSubtitleFromJson(json);
}
