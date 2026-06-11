import 'package:json_annotation/json_annotation.dart';

part 'tmdb_model.g.dart';

@JsonSerializable()
class TMDBDetail {
  TMDBDetail({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.cover,
    this.backdrop,
    required this.genres,
    required this.languages,
    required this.images,
    this.overview,
    required this.status,
    required this.casts,
    required this.releaseDate,
    required this.runtime,
    required this.originalTitle,
  });

  final int id;
  final String mediaType;
  final String title;
  final String cover;
  final String? backdrop;
  final List<String> genres;
  final List<String> languages;
  final List<String> images;
  final String? overview;
  final String status;
  final List<TMDBCast> casts;
  final String releaseDate;
  final int runtime;
  final String originalTitle;

  factory TMDBDetail.fromJson(Map<String, dynamic> json) =>
      _$TMDBDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TMDBDetailToJson(this);

  factory TMDBDetail.fromApi(Map<String, dynamic> json, String mediaType) {
    final credits = json['credits'] ?? {};
    final castList = (credits['cast'] as List? ?? [])
        .map((e) => TMDBCast.fromJson(e as Map<String, dynamic>))
        .toList();

    return TMDBDetail(
      id: json['id'],
      mediaType: mediaType,
      title: json['title'] ?? json['name'] ?? '',
      cover: json['poster_path'] != null
          ? "https://image.tmdb.org/t/p/w500${json['poster_path']}"
          : '',
      backdrop: json['backdrop_path'] != null
          ? "https://image.tmdb.org/t/p/original${json['backdrop_path']}"
          : null,
      genres: (json['genres'] as List? ?? [])
          .map((e) => e['name'] as String)
          .toList(),
      languages: (json['spoken_languages'] as List? ?? [])
          .map((e) => e['english_name'] as String)
          .toList(),
      images: ((json['images']?['backdrops'] as List? ?? [])
          .map((e) => "https://image.tmdb.org/t/p/original${e['file_path']}")
          .toList()),
      overview: json['overview'],
      status: json['status'] ?? '',
      casts: castList,
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      runtime:
          json['runtime'] ??
          (json['episode_run_time'] as List?)?.firstOrNull ??
          0,
      originalTitle: json['original_title'] ?? json['original_name'] ?? '',
    );
  }
}

@JsonSerializable()
class TMDBCast {
  TMDBCast({required this.name, required this.character, this.profilePath});

  final String name;
  final String character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;

  factory TMDBCast.fromJson(Map<String, dynamic> json) =>
      _$TMDBCastFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBCastToJson(this);
}
