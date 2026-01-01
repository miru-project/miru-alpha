import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:json_annotation/json_annotation.dart';
import './model.dart';

part 'user_data.g.dart';

int _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

@JsonSerializable()
class History {
  @JsonKey(fromJson: _parseInt)
  int id;

  String package;
  String url;
  String detailUrl;
  String? cover;

  // Store enum as String
  String type;
  int episodeGroupId;
  int episodeId;
  String title;
  String episodeTitle;
  int progress;
  int totalProgress;
  DateTime date;

  History({
    this.id = 0,
    required this.package,
    required this.url,
    required this.detailUrl,
    this.cover,
    required this.type,
    required this.episodeGroupId,
    required this.episodeId,
    required this.title,
    required this.episodeTitle,
    required this.progress,
    required this.totalProgress,
    required this.date,
  });

  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryToJson(this);

  static History fromProto(proto.History p) {
    return History(
      id: p.id,
      package: p.package,
      url: p.url,
      detailUrl: p.detailUrl,
      cover: p.cover.isEmpty ? null : p.cover,
      type: p.type,
      episodeGroupId: p.episodeGroupId,
      episodeId: p.episodeId,
      title: p.title,
      episodeTitle: p.episodeTitle,
      progress: p.progress,
      totalProgress: p.totalProgress,
      date: DateTime.parse(p.date),
    );
  }

  proto.History toProto() {
    return proto.History()
      ..id = id
      ..package = package
      ..url = url
      ..detailUrl = detailUrl
      ..cover = cover ?? ''
      ..type = type
      ..episodeGroupId = episodeGroupId
      ..episodeId = episodeId
      ..title = title
      ..episodeTitle = episodeTitle
      ..progress = progress
      ..totalProgress = totalProgress
      ..date = date.toUtc().toIso8601String();
  }
}

extension HistoryExtension on History {
  ExtensionType get extensionType => ExtensionType.values.firstWhere(
    (e) => e.toString().split('.').last == type,
    orElse: () => ExtensionType.manga,
  );

  set extensionType(ExtensionType value) {
    type = value.toString().split('.').last;
  }
}

@JsonSerializable()
class Favorite {
  @JsonKey(fromJson: _parseInt)
  int id;

  String package;
  String url;
  String type;
  String title;
  String? cover;
  DateTime date;

  Favorite({
    this.id = 0,
    required this.package,
    required this.url,
    required this.type,
    required this.title,
    this.cover,
    required this.date,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteToJson(this);

  static Favorite fromProto(proto.Favorite p) {
    return Favorite(
      id: p.id,
      package: p.package,
      url: p.url,
      type: p.type,
      title: p.title,
      cover: p.cover.isEmpty ? null : p.cover,
      date: DateTime.parse(p.date),
    );
  }

  proto.Favorite toProto() {
    return proto.Favorite()
      ..id = id
      ..package = package
      ..url = url
      ..type = type
      ..title = title
      ..cover = cover ?? ''
      ..date = date.toIso8601String();
  }
}

class EnumToString {
  static String convertToString<T extends Enum>(T type) {
    return type.toString().split('.').last;
  }

  static T convertToEnum<T extends Enum>(String input, Iterable<T> values) {
    return values.firstWhere(
      (v) => v.toString().split('.').last == input,
      orElse: () => throw ArgumentError(
        'No enum value for input "$input" in ${T.toString()}',
      ),
    );
  }
}

@JsonSerializable()
class FavoriateGroup {
  @JsonKey(fromJson: _parseInt)
  int id;

  String name;
  List<Favorite> favorites;
  DateTime date;

  FavoriateGroup({
    this.id = 0,
    required this.name,
    required this.date,
    this.favorites = const [],
  });

  factory FavoriateGroup.fromJson(Map<String, dynamic> json) =>
      _$FavoriateGroupFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriateGroupToJson(this);

  static FavoriateGroup fromProto(proto.FavoriteGroup p) {
    return FavoriateGroup(
      id: p.id,
      name: p.name,
      date: DateTime.parse(p.date),
      favorites: p.favorites.map((f) => Favorite.fromProto(f)).toList(),
    );
  }

  proto.FavoriteGroup toProto() {
    return proto.FavoriteGroup()
      ..id = id
      ..name = name
      ..date = date.toIso8601String()
      ..favorites.addAll(favorites.map((f) => f.toProto()));
  }
}

// Recored download for saving downlading progress
class DownloadRecord {
  int id;

  String saveDir;
  String url;
  int currentSegment;
  int totalSegment;

  DownloadRecord({
    this.id = 0,
    required this.saveDir,
    required this.url,
    required this.currentSegment,
    required this.totalSegment,
  });
}
