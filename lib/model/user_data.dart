import './model.dart';

class History {
  int id;

  String package;
  String url;
  String? cover;

  // Store enum as String
  String type;
  int episodeGroupId;
  int episodeId;
  String title;
  String episodeTitle;
  String progress;
  String totalProgress;
  DateTime date;

  History({
    this.id = 0,
    required this.package,
    required this.url,
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

  factory History.fromJson(Map<String, dynamic> json) => History(
    id: json['id'] ?? 0,
    package: json['package'],
    url: json['url'],
    cover: json['cover'],
    type: json['type'],
    episodeGroupId: json['episodeGroupId'],
    episodeId: json['episodeId'],
    title: json['title'],
    episodeTitle: json['episodeTitle'],
    progress: json['progress'],
    totalProgress: json['totalProgress'],
    date: DateTime.parse(json['date']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'package': package,
    'url': url,
    'cover': cover,
    'type': type,
    'episodeGroupId': episodeGroupId,
    'episodeId': episodeId,
    'title': title,
    'episodeTitle': episodeTitle,
    'progress': progress,
    'totalProgress': totalProgress,
    'date': date.toIso8601String(),
  };
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

class Favorite {
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

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: json['id'] ?? 0,
    package: json['package'],
    url: json['url'],
    type: json['type'],
    title: json['title'],
    cover: json['cover'],
    date: DateTime.parse(json['date']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'package': package,
    'url': url,
    'type': type,
    'title': title,
    'cover': cover,
    'date': date.toIso8601String(),
  };
}

class EnumToString {
  static String convertToString<T extends Enum>(T type) {
    return type.toString().split('.').last;
  }

  static T convertToEnum<T extends Enum>(String input, Iterable<T> values) {
    return values.firstWhere(
      (v) => v.toString().split('.').last == input,
      orElse:
          () =>
              throw ArgumentError(
                'No enum value for input "$input" in ${T.toString()}',
              ),
    );
  }
}

class FavoriateGroup {
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

  factory FavoriateGroup.fromJson(Map<String, dynamic> json) => FavoriateGroup(
    id: json['id'] ?? 0,
    name: json['name'],
    date: DateTime.parse(json['date']),
    favorites:
        (json['favorites'] as List?)
            ?.map((e) => Favorite.fromJson(e))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'favorites': favorites.map((e) => e.toJson()).toList(),
  };
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
