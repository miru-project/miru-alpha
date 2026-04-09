import 'package:json_annotation/json_annotation.dart';

part 'anilist_model.g.dart';

@JsonSerializable()
class AnilistUser {
  final String name;
  final int id;
  final AnilistAvatar avatar;
  final AnilistStatistics statistics;

  AnilistUser({
    required this.name,
    required this.id,
    required this.avatar,
    required this.statistics,
  });

  factory AnilistUser.fromJson(Map<String, dynamic> json) => _$AnilistUserFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistUserToJson(this);
}

@JsonSerializable()
class AnilistAvatar {
  final String? medium;
  final String? large;

  AnilistAvatar({this.medium, this.large});

  factory AnilistAvatar.fromJson(Map<String, dynamic> json) => _$AnilistAvatarFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistAvatarToJson(this);
}

@JsonSerializable()
class AnilistStatistics {
  final AnilistMediaStatistics anime;
  final AnilistMediaStatistics manga;

  AnilistStatistics({required this.anime, required this.manga});

  factory AnilistStatistics.fromJson(Map<String, dynamic> json) => _$AnilistStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistStatisticsToJson(this);
}

@JsonSerializable()
class AnilistMediaStatistics {
  final int episodesWatched;
  final int chaptersRead;

  AnilistMediaStatistics({this.episodesWatched = 0, this.chaptersRead = 0});

  factory AnilistMediaStatistics.fromJson(Map<String, dynamic> json) => _$AnilistMediaStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistMediaStatisticsToJson(this);
}

@JsonSerializable()
class AnilistCollection {
  final List<AnilistList> lists;

  AnilistCollection({required this.lists});

  factory AnilistCollection.fromJson(Map<String, dynamic> json) => _$AnilistCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistCollectionToJson(this);
}

@JsonSerializable()
class AnilistList {
  final String status;
  final List<AnilistEntry> entries;

  AnilistList({required this.status, required this.entries});

  factory AnilistList.fromJson(Map<String, dynamic> json) => _$AnilistListFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistListToJson(this);
}

@JsonSerializable()
class AnilistEntry {
  final int? id;
  final String status;
  final int progress;
  final double score;
  final AnilistMedia media;

  AnilistEntry({
    this.id,
    required this.status,
    required this.progress,
    required this.score,
    required this.media,
  });

  factory AnilistEntry.fromJson(Map<String, dynamic> json) => _$AnilistEntryFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistEntryToJson(this);
}

@JsonSerializable()
class AnilistMedia {
  final int id;
  final String status;
  final int? chapters;
  final int? episodes;
  final int? meanScore;
  final bool? isFavourite;
  final AnilistTitle title;
  final AnilistCoverImage coverImage;
  final NextAiringEpisode? nextAiringEpisode;

  AnilistMedia({
    required this.id,
    required this.status,
    this.chapters,
    this.episodes,
    this.meanScore,
    this.isFavourite,
    required this.title,
    required this.coverImage,
    this.nextAiringEpisode,
  });

  factory AnilistMedia.fromJson(Map<String, dynamic> json) => _$AnilistMediaFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistMediaToJson(this);
}

@JsonSerializable()
class AnilistTitle {
  final String? userPreferred;
  final String? english;
  final String? romaji;
  final String? native;

  AnilistTitle({this.userPreferred, this.english, this.romaji, this.native});

  factory AnilistTitle.fromJson(Map<String, dynamic> json) => _$AnilistTitleFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistTitleToJson(this);
}

@JsonSerializable()
class AnilistCoverImage {
  final String? large;
  final String? medium;

  AnilistCoverImage({this.large, this.medium});

  factory AnilistCoverImage.fromJson(Map<String, dynamic> json) => _$AnilistCoverImageFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistCoverImageToJson(this);
}

@JsonSerializable()
class NextAiringEpisode {
  final int episode;
  final int airingAt;

  NextAiringEpisode({required this.episode, this.airingAt = 0});

  factory NextAiringEpisode.fromJson(Map<String, dynamic> json) => _$NextAiringEpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$NextAiringEpisodeToJson(this);
}
