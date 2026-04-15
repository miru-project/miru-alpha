import 'package:dio/dio.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/http/request.dart';

enum AnilistType { anime, manga }

enum AnilistMediaListStatus {
  current,
  completed,
  planning,
  paused,
  dropped,
  repeating,
}

class AniListProvider {
  static const String apiUrl = 'https://graphql.anilist.co';

  static String _typeToQuery(AnilistType type) {
    return (type == AnilistType.anime) ? "ANIME" : "MANGA";
  }

  static String mediaListStatusToQuery(
    AnilistMediaListStatus status, {
    bool firstLetterUpperCase = false,
  }) {
    switch (status) {
      case AnilistMediaListStatus.current:
        return "CURRENT";
      case AnilistMediaListStatus.completed:
        return "COMPLETED";
      case AnilistMediaListStatus.planning:
        return "PLANNING";
      case AnilistMediaListStatus.paused:
        return "PAUSED";
      case AnilistMediaListStatus.dropped:
        return "DROPPED";
      case AnilistMediaListStatus.repeating:
        return "REPEATING";
    }
  }

  static String mediaListStatusToTranslate(
    AnilistMediaListStatus status,
    AnilistType type,
  ) {
    switch (status) {
      case AnilistMediaListStatus.current:
        return (type == AnilistType.anime)
            ? "anilist.watching".i18n
            : "anilist.reading".i18n;
      case AnilistMediaListStatus.completed:
        return "anilist.completed".i18n;
      case AnilistMediaListStatus.planning:
        return "anilist.planning".i18n;
      case AnilistMediaListStatus.paused:
        return "anilist.hold-on".i18n;
      case AnilistMediaListStatus.dropped:
        return "anilist.dropped".i18n;
      case AnilistMediaListStatus.repeating:
        return (type == AnilistType.anime)
            ? "anilist.re-watching".i18n
            : "anilist.re-reading".i18n;
    }
  }

  static AnilistMediaListStatus stringToMediaListStatus(String status) {
    switch (status) {
      case "CURRENT":
        return AnilistMediaListStatus.current;
      case "COMPLETED":
        return AnilistMediaListStatus.completed;
      case "PLANNING":
        return AnilistMediaListStatus.planning;
      case "PAUSED":
        return AnilistMediaListStatus.paused;
      case "DROPPED":
        return AnilistMediaListStatus.dropped;
      case "REPEATING":
        return AnilistMediaListStatus.repeating;
      default:
        return AnilistMediaListStatus.current;
    }
  }

  static Future<void> logout() async {
    await MiruRequest.rawGet('http://127.0.0.1:3000/anilist/logout');
  }

  static Future postRequest({
    Map<String, dynamic>? varibale,
    required String queryString,
  }) async {
    try {
      final response = await MiruRequest.post(
        apiUrl,
        {"query": queryString},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      logger.info(e);
    }
  }

  static Future<AnilistUser> getuserData() async {
    const userDataQuery =
        """{Viewer {name  id avatar{medium} statistics{anime{episodesWatched}manga{chaptersRead}}}}""";
    final response = await postRequest(queryString: userDataQuery);
    return AnilistUser.fromJson(response["data"]["Viewer"]);
  }

  static Future<List<AnilistList>> getCollection(
    AnilistType anilistType,
    int userid,
  ) async {
    final query =
        """
      {
        MediaListCollection(userId: $userid, type : ${_typeToQuery(anilistType)}) {
          lists {
            status
            entries {
              id
              status
              progress
              score
              media {
                id
                status
                chapters
                episodes
                meanScore
                isFavourite
                nextAiringEpisode {
                  episode
                }
                coverImage {
                  large
                }
                title {
                  userPreferred
                }
              }
            }
          }
        }
      }
      """;
    final res = await postRequest(queryString: query);
    final lists = res["data"]["MediaListCollection"]["lists"] as List;
    return lists
        .map((e) => AnilistList.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AnilistMedia>> mediaQuerypage({
    required String searchString,
    required AnilistType type,
    int? page,
  }) async {
    final String nameQuery =
        """{Page(page:${page ?? 1}){
    media(search:"$searchString",type:${_typeToQuery(type)}){
        id
        type
        seasonYear
        isAdult
        description
        status
        season
        startDate{
            year
            month
            day
        }
        endDate{
            year
            month
            day
        }
        coverImage{
            large
        }
        title{
            romaji
            english
            native
            userPreferred 
        }
    }
  }}
  """;
    final res = await postRequest(queryString: nameQuery);
    final media = res["data"]["Page"]["media"] as List;
    return media
        .map((e) => AnilistMedia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<int> editList({
    required AnilistMediaListStatus status,
    int? mediaId,
    int? id,
    int? progress,
    double? score,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPrivate,
  }) async {
    final queryList = [];
    if (id == null) {
      queryList.add("mediaId:$mediaId");
    } else {
      queryList.add("id:$id");
    }

    if (score != null) {
      queryList.add("score:$score");
    }

    if (progress != null) {
      queryList.add("progress:$progress");
    }

    if (startDate != null) {
      queryList.add(
        "startedAt:{year:${startDate.year},month:${startDate.month},day:${startDate.day}}",
      );
    }

    if (endDate != null) {
      queryList.add(
        "completedAt:{year:${endDate.year},month:${endDate.month},day:${endDate.day}}",
      );
    }

    final queryStr = queryList.join(",");

    final queryString =
        """mutation{
    SaveMediaListEntry(status:${mediaListStatusToQuery(status)},private:${isPrivate ?? false},$queryStr){
        id
      }
    }""";

    final res = await postRequest(queryString: queryString);
    return res["data"]["SaveMediaListEntry"]["id"];
  }

  static Future<bool> deleteList({required int id}) async {
    final String deleteMutation =
        """
    mutation{
        DeleteMediaListEntry(id:$id){
              deleted
      }
    }
    """;
    final res = await postRequest(queryString: deleteMutation);
    return res["data"]["DeleteMediaListEntry"]["deleted"];
  }

  static Future<AnilistMedia> getMediaList(int id) async {
    final query =
        """
{
   Media(id: $id) {
    id
    title {
      userPreferred
    }
    coverImage {
      large
    }
    bannerImage
    type
    status
    episodes
    chapters
    volumes
    isFavourite
    characters(sort: [ROLE, RELEVANCE, ID]) {
      edges {
        role
        node {
          id
          name {
            full
            native
          }
          image {
            large
            medium
          }
        }
        voiceActors(language: JAPANESE, sort: [RELEVANCE, ID]) {
          id
          name {
            full
            native
          }
          image {
            large
            medium
          }
        }
      }
    }
    mediaListEntry {
      id
      mediaId
      status
      score
      advancedScores
      progress
      progressVolumes
      repeat
      priority
      private
      hiddenFromStatusLists
      customLists
      notes
      updatedAt
      startedAt {
        year
        month
        day
      }
      completedAt {
        year
        month
        day
      }
      user {
        id
        name
      }
    }
  }
}
""";
    final res = await postRequest(queryString: query);
    return AnilistMedia.fromJson(res["data"]["Media"]);
  }
}
