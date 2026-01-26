import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/provider/watch/main_provider.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
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
  @override
  late String imageUrl;
  @override
  late String package;
  @override
  late ExtensionType type;
  @override
  late String detailUrl;
  late EpisodeNotifierState _capturedState;

  @override
  set state(EpisodeNotifierState value) {
    _capturedState = value;
    super.state = value;
  }

  @override
  EpisodeNotifierState build(
    int groupIndex,
    int episodeIndex,
    List<ExtensionEpisodeGroup> epGroup,
    String name,
    bool flag,
    String imageUrl,
    String detailUrl,
    ExtensionType type,
    String package,
  ) {
    this.imageUrl = imageUrl;
    this.package = package;
    this.type = type;
    this.detailUrl = detailUrl;

    final initialState = EpisodeNotifierState(
      epGroup: epGroup,
      flag: flag,
      name: name,
      selectedGroupIndex: groupIndex,
      selectedEpisodeIndex: episodeIndex,
    );
    _capturedState = initialState;

    ref.onDispose(() {
      final s = _capturedState;
      // Run async operation decoupled from the synchronous dispose cycle
      Future(() async {
        try {
          final history = History(
            title: s.name,
            package: this.package,
            type: this.type.toString(),
            episodeGroupId: s.selectedGroupIndex,
            episodeId: s.selectedEpisodeIndex,
            progress: s.selectedEpisodeIndex,
            cover: this.imageUrl,
            totalProgress: s.epGroup[s.selectedGroupIndex].urls.length,
            episodeTitle: s
                .epGroup[s.selectedGroupIndex]
                .urls[s.selectedEpisodeIndex]
                .name,
            url: s
                .epGroup[s.selectedGroupIndex]
                .urls[s.selectedEpisodeIndex]
                .url,
            detailUrl: this.detailUrl,
            date: DateTime.now(),
          );
          await DatabaseService.putHistory(history);
          ref.read(mainProvider.notifier).addHistory(history);
          ref.read(detialProvider.notifier).putHistory(history);
        } catch (e) {
          logger.info(e);
        }
      });
    });

    return initialState;
  }

  void selectEpisode(int groupIndex, int episodeIndex) {
    state = state.copyWith(
      selectedGroupIndex: groupIndex,
      selectedEpisodeIndex: episodeIndex,
    );
  }

  void putInformation(
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

  int get epLength => state.epGroup[state.selectedGroupIndex].urls.length;
  int get selectedIndex => state.selectedEpisodeIndex;
  int get selectedGroupIndex => state.selectedGroupIndex;
}
