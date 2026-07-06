import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/domain/models/download.dart';
import 'package:miru_alpha/domain/models/history.dart';
import 'package:miru_alpha/domain/models/favorite.dart';

part 'home.freezed.dart';
part 'home.g.dart';

enum HomeTab { library, history, favorite, download }

@freezed
abstract class DomainHomeState with _$DomainHomeState {
  const factory DomainHomeState({
    @Default(HomeTab.library) HomeTab selectedTab,
    required List<DomainExtensionMeta> libraryExtensions,
    required List<DomainHistoryItem> historyItems,
    required List<DomainFavoriteGroup> favoriteGroups,
    required List<DomainFavorite> favorites,
    required List<DomainDownload> activeDownloads,
    required List<DomainDownload> finishedDownloads,
    @Default(false) bool isLoading,
    String? error,
  }) = _DomainHomeState;

  factory DomainHomeState.fromJson(Map<String, dynamic> json) =>
      _$DomainHomeStateFromJson(json);
}

@freezed
abstract class DomainLibrarySection with _$DomainLibrarySection {
  const factory DomainLibrarySection({
    required List<DomainExtensionMeta> extensions,
    required List<String> pinnedPackages,
    String? query,
  }) = _DomainLibrarySection;

  factory DomainLibrarySection.fromJson(Map<String, dynamic> json) =>
      _$DomainLibrarySectionFromJson(json);
}
