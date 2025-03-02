import 'package:objectbox/objectbox.dart';
import './model.dart';

@Entity()
class History {
  @Id()
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
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
  @Property(type: PropertyType.date)
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

  // Convert enum to/from String
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

@Entity()
class MangaSetting {
  @Id()
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
  String url;
  String readMode;

  MangaSetting({this.id = 0, required this.url, required this.readMode});
}

extension MangaSettingExtension on MangaSetting {
  MangaReadMode get mangaReadMode => MangaReadMode.values.firstWhere(
    (e) => e.toString().split('.').last == readMode,
    orElse: () => MangaReadMode.standard,
  );

  set mangaReadMode(MangaReadMode value) {
    readMode = value.toString().split('.').last;
  }
}

@Entity()
class MiruDetail {
  @Id()
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
  String package;
  String url;
  String data;
  int? tmdbID;
  @Property(type: PropertyType.date)
  DateTime updateTime;
  String? aniListID;

  MiruDetail({
    this.id = 0,
    required this.package,
    required this.url,
    required this.data,
    this.tmdbID,
    required this.updateTime,
    this.aniListID,
  });
}

@Entity()
class Favorite {
  @Id()
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
  String package;
  String url;
  String type;
  String title;
  String? cover;
  @Property(type: PropertyType.date)
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

@Entity()
class FavoriateGroup {
  @Id()
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
  String name;
  final favorite = ToMany<Favorite>();
  @Property(type: PropertyType.date)
  DateTime date;

  FavoriateGroup({this.id = 0, required this.name, required this.date});
}

// Recored download for saving downlading progress
@Entity()
class DownloadRecord {
  @Id()
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
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
