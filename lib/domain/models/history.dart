import 'package:freezed_annotation/freezed_annotation.dart';

part 'history.freezed.dart';
part 'history.g.dart';

@freezed
abstract class DomainHistoryItem with _$DomainHistoryItem {
  const factory DomainHistoryItem({
    required String id,
    required String package,
    required String detailUrl,
    required String title,
    String? cover,
    required int episodeIndex,
    String? episodeTitle,
    required int watchedDuration,
    required int totalDuration,
    required double progress,
    required DateTime watchedAt,
    String? lastPosition,
  }) = _DomainHistoryItem;

  factory DomainHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$DomainHistoryItemFromJson(json);
}
