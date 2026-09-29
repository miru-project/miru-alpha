// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainDownload _$DomainDownloadFromJson(Map<String, dynamic> json) =>
    _DomainDownload(
      id: json['id'] as String,
      package: json['package'] as String,
      detailUrl: json['detailUrl'] as String,
      title: json['title'] as String,
      episode: json['episode'] as String,
      cover: json['cover'] as String?,
      progress: (json['progress'] as num).toDouble(),
      status: $enumDecode(_$DownloadStatusEnumMap, json['status']),
      speed: (json['speed'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      downloadedBytes: (json['downloadedBytes'] as num?)?.toInt(),
      error: json['error'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DomainDownloadToJson(_DomainDownload instance) =>
    <String, dynamic>{
      'id': instance.id,
      'package': instance.package,
      'detailUrl': instance.detailUrl,
      'title': instance.title,
      'episode': instance.episode,
      'cover': instance.cover,
      'progress': instance.progress,
      'status': _$DownloadStatusEnumMap[instance.status]!,
      'speed': instance.speed,
      'size': instance.size,
      'downloadedBytes': instance.downloadedBytes,
      'error': instance.error,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$DownloadStatusEnumMap = {
  DownloadStatus.pending: 'pending',
  DownloadStatus.downloading: 'downloading',
  DownloadStatus.paused: 'paused',
  DownloadStatus.completed: 'completed',
  DownloadStatus.failed: 'failed',
  DownloadStatus.cancelled: 'cancelled',
};

_DomainDownloadProgress _$DomainDownloadProgressFromJson(
  Map<String, dynamic> json,
) => _DomainDownloadProgress(
  downloadId: json['downloadId'] as String,
  progress: (json['progress'] as num).toDouble(),
  speed: (json['speed'] as num).toInt(),
  downloadedBytes: (json['downloadedBytes'] as num).toInt(),
  totalBytes: (json['totalBytes'] as num).toInt(),
  status: $enumDecodeNullable(_$DownloadStatusEnumMap, json['status']),
  error: json['error'] as String?,
);

Map<String, dynamic> _$DomainDownloadProgressToJson(
  _DomainDownloadProgress instance,
) => <String, dynamic>{
  'downloadId': instance.downloadId,
  'progress': instance.progress,
  'speed': instance.speed,
  'downloadedBytes': instance.downloadedBytes,
  'totalBytes': instance.totalBytes,
  'status': _$DownloadStatusEnumMap[instance.status],
  'error': instance.error,
};
