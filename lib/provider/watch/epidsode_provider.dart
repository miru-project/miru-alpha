import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/provider/history_page_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
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
  static int progress = 0;
  static int totalProgress = 1;
  late String imageUrl;
  late String package;
  late ExtensionType type;
  late String detailUrl;
  late EpisodeNotifierState _capturedState;
  late DetialProvider? detailPr;

  @override
  set state(EpisodeNotifierState value) {
    _capturedState = value;
    super.state = value;
  }

  @override
  EpisodeNotifierState build(WatchParams param) {
    imageUrl = param.detailImageUrl;
    package = param.meta.packageName;
    type = param.type;
    detailUrl = param.detailUrl;
    detailPr = param.detailPr;

    final initialState = EpisodeNotifierState(
      epGroup: param.epGroup ?? [],
      name: param.name,
      selectedGroupIndex: param.selectedGroupIndex,
      selectedEpisodeIndex: param.selectedEpisodeIndex,
    );
    _capturedState = initialState;

    // ref.onDispose(() );

    return initialState;
  }

  void saveHistory() {
    final s = _capturedState;
    final ep = s.epGroup[s.selectedGroupIndex].urls[s.selectedEpisodeIndex];
    final history = History(
      title: s.name,
      package: package,
      type: type.name,
      episodeGroupId: s.selectedGroupIndex,
      episodeId: s.selectedEpisodeIndex,
      progress: progress,
      cover: imageUrl,
      totalProgress: totalProgress,
      episodeTitle: ep.name,
      url: ep.url,
      detailUrl: detailUrl,
      date: DateTime.now(),
    );
    Future.microtask(() {
      ref.read(historyPageProvider.notifier).addHistory(history);
      if (detailPr == null) return;
      // Put the history to detail for update the history list
      ref.read(detailPr!.notifier).putHistory(history);
    });
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
