import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracking.freezed.dart';
part 'tracking.g.dart';

@freezed
abstract class DomainTrackingAccount with _$DomainTrackingAccount {
  const factory DomainTrackingAccount({
    required int id,
    required String name,
    String? avatar,
    required TrackingProvider provider,
  }) = _DomainTrackingAccount;

  factory DomainTrackingAccount.fromJson(Map<String, dynamic> json) =>
      _$DomainTrackingAccountFromJson(json);
}

enum TrackingProvider { anilist, tmdb }

@freezed
abstract class DomainTrackingProgress with _$DomainTrackingProgress {
  const factory DomainTrackingProgress({
    required int id,
    required int mediaId,
    required String status,
    required int progress,
    double? score,
    String? mediaType,
    String? title,
    String? cover,
  }) = _DomainTrackingProgress;

  factory DomainTrackingProgress.fromJson(Map<String, dynamic> json) =>
      _$DomainTrackingProgressFromJson(json);
}

@freezed
abstract class DomainTMDBTrack with _$DomainTMDBTrack {
  const factory DomainTMDBTrack({
    required int id,
    required int mediaId,
    required String mediaType,
    required String title,
    String? cover,
    String? overview,
    String? status,
    int? runtime,
    List<String>? genres,
    required DateTime updatedAt,
  }) = _DomainTMDBTrack;

  factory DomainTMDBTrack.fromJson(Map<String, dynamic> json) =>
      _$DomainTMDBTrackFromJson(json);
}

@freezed
abstract class DomainTMDBCast with _$DomainTMDBCast {
  const factory DomainTMDBCast({
    required String name,
    required String character,
    String? profilePath,
  }) = _DomainTMDBCast;

  factory DomainTMDBCast.fromJson(Map<String, dynamic> json) =>
      _$DomainTMDBCastFromJson(json);
}
