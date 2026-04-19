// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anilist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnilistUser _$AnilistUserFromJson(Map<String, dynamic> json) => AnilistUser(
  name: json['name'] as String,
  id: (json['id'] as num).toInt(),
  avatar: AnilistAvatar.fromJson(json['avatar'] as Map<String, dynamic>),
  statistics: AnilistStatistics.fromJson(
    json['statistics'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AnilistUserToJson(AnilistUser instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'avatar': instance.avatar,
      'statistics': instance.statistics,
    };

AnilistAvatar _$AnilistAvatarFromJson(Map<String, dynamic> json) =>
    AnilistAvatar(
      medium: json['medium'] as String?,
      large: json['large'] as String?,
    );

Map<String, dynamic> _$AnilistAvatarToJson(AnilistAvatar instance) =>
    <String, dynamic>{'medium': instance.medium, 'large': instance.large};

AnilistStatistics _$AnilistStatisticsFromJson(
  Map<String, dynamic> json,
) => AnilistStatistics(
  anime: AnilistMediaStatistics.fromJson(json['anime'] as Map<String, dynamic>),
  manga: AnilistMediaStatistics.fromJson(json['manga'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnilistStatisticsToJson(AnilistStatistics instance) =>
    <String, dynamic>{'anime': instance.anime, 'manga': instance.manga};

AnilistMediaStatistics _$AnilistMediaStatisticsFromJson(
  Map<String, dynamic> json,
) => AnilistMediaStatistics(
  episodesWatched: (json['episodesWatched'] as num?)?.toInt() ?? 0,
  chaptersRead: (json['chaptersRead'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AnilistMediaStatisticsToJson(
  AnilistMediaStatistics instance,
) => <String, dynamic>{
  'episodesWatched': instance.episodesWatched,
  'chaptersRead': instance.chaptersRead,
};

AnilistCollection _$AnilistCollectionFromJson(Map<String, dynamic> json) =>
    AnilistCollection(
      lists: (json['lists'] as List<dynamic>)
          .map((e) => AnilistList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnilistCollectionToJson(AnilistCollection instance) =>
    <String, dynamic>{'lists': instance.lists};

AnilistList _$AnilistListFromJson(Map<String, dynamic> json) => AnilistList(
  status: json['status'] as String,
  entries: (json['entries'] as List<dynamic>)
      .map((e) => AnilistEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AnilistListToJson(AnilistList instance) =>
    <String, dynamic>{'status': instance.status, 'entries': instance.entries};

AnilistEntry _$AnilistEntryFromJson(Map<String, dynamic> json) => AnilistEntry(
  id: (json['id'] as num?)?.toInt(),
  status: json['status'] as String,
  progress: (json['progress'] as num).toInt(),
  score: (json['score'] as num).toDouble(),
  media: json['media'] == null
      ? null
      : AnilistMedia.fromJson(json['media'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnilistEntryToJson(AnilistEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'progress': instance.progress,
      'score': instance.score,
      'media': instance.media,
    };

AnilistMedia _$AnilistMediaFromJson(Map<String, dynamic> json) => AnilistMedia(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String?,
  status: json['status'] as String,
  chapters: (json['chapters'] as num?)?.toInt(),
  episodes: (json['episodes'] as num?)?.toInt(),
  meanScore: (json['meanScore'] as num?)?.toInt(),
  description: json['description'] as String?,
  isFavourite: json['isFavourite'] as bool?,
  title: AnilistTitle.fromJson(json['title'] as Map<String, dynamic>),
  coverImage: AnilistCoverImage.fromJson(
    json['coverImage'] as Map<String, dynamic>,
  ),
  nextAiringEpisode: json['nextAiringEpisode'] == null
      ? null
      : NextAiringEpisode.fromJson(
          json['nextAiringEpisode'] as Map<String, dynamic>,
        ),
  characters: json['characters'] == null
      ? null
      : AnilistCharacterConnection.fromJson(
          json['characters'] as Map<String, dynamic>,
        ),
  mediaListEntry: json['mediaListEntry'] == null
      ? null
      : AnilistEntry.fromJson(json['mediaListEntry'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnilistMediaToJson(AnilistMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'chapters': instance.chapters,
      'episodes': instance.episodes,
      'meanScore': instance.meanScore,
      'description': instance.description,
      'isFavourite': instance.isFavourite,
      'title': instance.title,
      'coverImage': instance.coverImage,
      'nextAiringEpisode': instance.nextAiringEpisode,
      'characters': instance.characters,
      'mediaListEntry': instance.mediaListEntry,
    };

AnilistTitle _$AnilistTitleFromJson(Map<String, dynamic> json) => AnilistTitle(
  userPreferred: json['userPreferred'] as String?,
  english: json['english'] as String?,
  romaji: json['romaji'] as String?,
  native: json['native'] as String?,
);

Map<String, dynamic> _$AnilistTitleToJson(AnilistTitle instance) =>
    <String, dynamic>{
      'userPreferred': instance.userPreferred,
      'english': instance.english,
      'romaji': instance.romaji,
      'native': instance.native,
    };

AnilistCoverImage _$AnilistCoverImageFromJson(Map<String, dynamic> json) =>
    AnilistCoverImage(
      large: json['large'] as String?,
      medium: json['medium'] as String?,
    );

Map<String, dynamic> _$AnilistCoverImageToJson(AnilistCoverImage instance) =>
    <String, dynamic>{'large': instance.large, 'medium': instance.medium};

NextAiringEpisode _$NextAiringEpisodeFromJson(Map<String, dynamic> json) =>
    NextAiringEpisode(
      episode: (json['episode'] as num).toInt(),
      airingAt: (json['airingAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$NextAiringEpisodeToJson(NextAiringEpisode instance) =>
    <String, dynamic>{
      'episode': instance.episode,
      'airingAt': instance.airingAt,
    };

AnilistCharacterConnection _$AnilistCharacterConnectionFromJson(
  Map<String, dynamic> json,
) => AnilistCharacterConnection(
  edges: (json['edges'] as List<dynamic>?)
      ?.map((e) => AnilistCharacterEdge.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AnilistCharacterConnectionToJson(
  AnilistCharacterConnection instance,
) => <String, dynamic>{'edges': instance.edges};

AnilistCharacterEdge _$AnilistCharacterEdgeFromJson(
  Map<String, dynamic> json,
) => AnilistCharacterEdge(
  node: json['node'] == null
      ? null
      : AnilistCharacter.fromJson(json['node'] as Map<String, dynamic>),
  role: json['role'] as String?,
  voiceActors: (json['voiceActors'] as List<dynamic>?)
      ?.map((e) => AnilistStaff.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AnilistCharacterEdgeToJson(
  AnilistCharacterEdge instance,
) => <String, dynamic>{
  'node': instance.node,
  'role': instance.role,
  'voiceActors': instance.voiceActors,
};

AnilistCharacter _$AnilistCharacterFromJson(Map<String, dynamic> json) =>
    AnilistCharacter(
      id: (json['id'] as num).toInt(),
      name: AnilistName.fromJson(json['name'] as Map<String, dynamic>),
      image: json['image'] == null
          ? null
          : AnilistImage.fromJson(json['image'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnilistCharacterToJson(AnilistCharacter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };

AnilistStaff _$AnilistStaffFromJson(Map<String, dynamic> json) => AnilistStaff(
  id: (json['id'] as num).toInt(),
  name: AnilistName.fromJson(json['name'] as Map<String, dynamic>),
  image: json['image'] == null
      ? null
      : AnilistImage.fromJson(json['image'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnilistStaffToJson(AnilistStaff instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };

AnilistName _$AnilistNameFromJson(Map<String, dynamic> json) => AnilistName(
  full: json['full'] as String?,
  native: json['native'] as String?,
);

Map<String, dynamic> _$AnilistNameToJson(AnilistName instance) =>
    <String, dynamic>{'full': instance.full, 'native': instance.native};

AnilistImage _$AnilistImageFromJson(Map<String, dynamic> json) => AnilistImage(
  large: json['large'] as String?,
  medium: json['medium'] as String?,
);

Map<String, dynamic> _$AnilistImageToJson(AnilistImage instance) =>
    <String, dynamic>{'large': instance.large, 'medium': instance.medium};
