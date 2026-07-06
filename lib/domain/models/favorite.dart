import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite.freezed.dart';
part 'favorite.g.dart';

@freezed
abstract class DomainFavorite with _$DomainFavorite {
  const factory DomainFavorite({
    required String id,
    required String package,
    required String detailUrl,
    required String title,
    String? cover,
    required String type,
    required String groupId,
    required DateTime createdAt,
    String? description,
  }) = _DomainFavorite;

  factory DomainFavorite.fromJson(Map<String, dynamic> json) =>
      _$DomainFavoriteFromJson(json);
}

@freezed
abstract class DomainFavoriteGroup with _$DomainFavoriteGroup {
  const factory DomainFavoriteGroup({
    required String id,
    required String name,
    required String type,
    required int order,
    required DateTime createdAt,
    String? icon,
  }) = _DomainFavoriteGroup;

  factory DomainFavoriteGroup.fromJson(Map<String, dynamic> json) =>
      _$DomainFavoriteGroupFromJson(json);
}
