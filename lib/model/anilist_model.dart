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
  final AnilistCharacterConnection? characters;

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
    this.characters,
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

@JsonSerializable()
class AnilistCharacterConnection {
  final List<AnilistCharacterEdge>? edges;

  AnilistCharacterConnection({this.edges});

  factory AnilistCharacterConnection.fromJson(Map<String, dynamic> json) => _$AnilistCharacterConnectionFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistCharacterConnectionToJson(this);
}

@JsonSerializable()
class AnilistCharacterEdge {
  final AnilistCharacter? node;
  final String? role;
  final List<AnilistStaff>? voiceActors;

  AnilistCharacterEdge({this.node, this.role, this.voiceActors});

  factory AnilistCharacterEdge.fromJson(Map<String, dynamic> json) => _$AnilistCharacterEdgeFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistCharacterEdgeToJson(this);
}

@JsonSerializable()
class AnilistCharacter {
  final int id;
  final AnilistName name;
  final AnilistImage? image;

  AnilistCharacter({required this.id, required this.name, this.image});

  factory AnilistCharacter.fromJson(Map<String, dynamic> json) => _$AnilistCharacterFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistCharacterToJson(this);
}

@JsonSerializable()
class AnilistStaff {
  final int id;
  final AnilistName name;
  final AnilistImage? image;

  AnilistStaff({required this.id, required this.name, this.image});

  factory AnilistStaff.fromJson(Map<String, dynamic> json) => _$AnilistStaffFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistStaffToJson(this);
}

@JsonSerializable()
class AnilistName {
  final String? full;
  final String? native;

  AnilistName({this.full, this.native});

  factory AnilistName.fromJson(Map<String, dynamic> json) => _$AnilistNameFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistNameToJson(this);
}

@JsonSerializable()
class AnilistImage {
  final String? large;
  final String? medium;

  AnilistImage({this.large, this.medium});

  factory AnilistImage.fromJson(Map<String, dynamic> json) => _$AnilistImageFromJson(json);
  Map<String, dynamic> toJson() => _$AnilistImageToJson(this);
}
