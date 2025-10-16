import 'dart:developer';

import 'package:miru_app_new/model/index.dart';
// import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'epidsode_provider.g.dart';

class EpisodeNotifierState {
  final List<ExtensionEpisodeGroup> epGroup;
  final int selectedGroupIndex;
  final int selectedEpisodeIndex;
  final String name;
  final bool flag;
  EpisodeNotifierState({
    this.epGroup = const [],
    this.selectedGroupIndex = 0,
    this.name = '',
    this.flag = false,
    this.selectedEpisodeIndex = 0,
  });
  EpisodeNotifierState copyWith({
    List<ExtensionEpisodeGroup>? epGroup,
    String? name,
    bool? flag,
    int? selectedGroupIndex,
    int? selectedEpisodeIndex,
  }) {
    return EpisodeNotifierState(
      epGroup: epGroup ?? this.epGroup,
      flag: flag ?? this.flag,
      name: name ?? this.name,
      selectedGroupIndex: selectedGroupIndex ?? this.selectedGroupIndex,
      selectedEpisodeIndex: selectedEpisodeIndex ?? this.selectedEpisodeIndex,
    );
  }
}

@riverpod
class EpisodeNotifier extends _$EpisodeNotifier {
  late String imageUrl;
  late String package;
  late ExtensionType type;
  late String detailUrl;
  @override
  EpisodeNotifierState build(
    int groupIndex,
    int episodeIndex,
    List<ExtensionEpisodeGroup> epGroup,
    String name,
    bool flag,
  ) {
    ref.onDispose(() {
      // DatabaseService.putHistory(
      //   History(
      //     title: state.name,
      //     package: package,
      //     type: EnumToString.convertToString(type),
      //     episodeGroupId: state.selectedGroupIndex,
      //     episodeId: state.selectedEpisodeIndex,
      //     progress: state.selectedEpisodeIndex.toString(),
      //     cover: imageUrl,
      //     totalProgress: state.epGroup[state.selectedGroupIndex].urls.length
      //         .toString(),
      //     episodeTitle: state
      //         .epGroup[state.selectedGroupIndex]
      //         .urls[state.selectedEpisodeIndex]
      //         .name,
      //     url: detailUrl,
      //     date: DateTime.now(),
      //   ),
      // );
    });

    return EpisodeNotifierState(
      epGroup: epGroup,
      flag: flag,
      name: name,
      selectedGroupIndex: groupIndex,
      selectedEpisodeIndex: episodeIndex,
    );
  }

  void selectEpisode(int groupIndex, int episodeIndex) {
    state = state.copyWith(
      selectedGroupIndex: groupIndex,
      selectedEpisodeIndex: episodeIndex,
    );
  }

  void putinformation(
    ExtensionType type,
    String package,
    String imageUrl,
    String detailUrl,
  ) {
    this.package = package;
    this.type = type;
    this.imageUrl = imageUrl;
    this.detailUrl = detailUrl;
  }

  // dispose behavior moved to ref.onDispose in build()
}
