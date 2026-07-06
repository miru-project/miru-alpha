// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainVideoPlayerState _$DomainVideoPlayerStateFromJson(
  Map<String, dynamic> json,
) => _DomainVideoPlayerState(
  showSettings: json['showSettings'] as bool? ?? false,
  showControls: json['showControls'] as bool? ?? false,
  isPlaying: json['isPlaying'] as bool? ?? false,
  position: json['position'] == null
      ? Duration.zero
      : Duration(microseconds: (json['position'] as num).toInt()),
  duration: json['duration'] == null
      ? Duration.zero
      : Duration(microseconds: (json['duration'] as num).toInt()),
  speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
  currentSubtitle: json['currentSubtitle'] as String? ?? '',
  qualityMap:
      (json['qualityMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  ratio: (json['ratio'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$DomainVideoPlayerStateToJson(
  _DomainVideoPlayerState instance,
) => <String, dynamic>{
  'showSettings': instance.showSettings,
  'showControls': instance.showControls,
  'isPlaying': instance.isPlaying,
  'position': instance.position.inMicroseconds,
  'duration': instance.duration.inMicroseconds,
  'speed': instance.speed,
  'currentSubtitle': instance.currentSubtitle,
  'qualityMap': instance.qualityMap,
  'ratio': instance.ratio,
};

_DomainVideoQuality _$DomainVideoQualityFromJson(Map<String, dynamic> json) =>
    _DomainVideoQuality(
      label: json['label'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$DomainVideoQualityToJson(_DomainVideoQuality instance) =>
    <String, dynamic>{'label': instance.label, 'url': instance.url};

_DomainSubtitle _$DomainSubtitleFromJson(Map<String, dynamic> json) =>
    _DomainSubtitle(
      name: json['name'] as String?,
      url: json['url'] as String,
      lang: json['lang'] as String?,
    );

Map<String, dynamic> _$DomainSubtitleToJson(_DomainSubtitle instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'lang': instance.lang,
    };
