import 'dart:async';

import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
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

  /// Saves an explicit snapshot; no shared progress between watch sessions.
  void saveHistory({int progress = 0, int totalProgress = 1}) {
    unawaited(
      prepareHistorySave(progress: progress, totalProgress: totalProgress)(),
    );
  }

  /// Captures dependencies while mounted for safe reader teardown.
  Future<void> Function() prepareHistorySave({
    required int progress,
    required int totalProgress,
  }) {
    final s = _capturedState;
    if (totalProgress <= 0 ||
        s.selectedGroupIndex < 0 ||
        s.selectedGroupIndex >= s.epGroup.length) {
      return () async {};
    }
    final episodes = s.epGroup[s.selectedGroupIndex].urls;
    if (s.selectedEpisodeIndex < 0 ||
        s.selectedEpisodeIndex >= episodes.length) {
      return () async {};
    }
    final ep = episodes[s.selectedEpisodeIndex];
    final historyWriter = ref.read(historyPageProvider.notifier);
    final detail = detailPr;
    final detailWriter = detail == null ? null : ref.read(detail.notifier);
    final trackers = detail == null
        ? <proto.Tracker>[]
        : ref.read(detail).detailInfo?.trackers.toList() ?? <proto.Tracker>[];
    final history = History(
      title: s.name,
      package: package,
      type: type.name,
      episodeGroupId: s.selectedGroupIndex,
      episodeId: s.selectedEpisodeIndex,
      progress: progress.clamp(0, totalProgress),
      cover: imageUrl,
      totalProgress: totalProgress,
      episodeTitle: ep.name,
      url: ep.url,
      detailUrl: detailUrl,
      date: DateTime.now(),
    );
    var saved = false;
    return () async {
      if (saved) return;
      saved = true;
      // Defer provider mutations beyond widget teardown.
      await Future<void>.value();
      try {
        history.date = DateTime.now();
        await historyWriter.addHistory(history);
        detailWriter?.putHistory(history);
      } catch (error, stack) {
        logger.severe('Failed to save watch history', error, stack);
        return;
      }

      if ((history.progress / history.totalProgress) >= 0.9) {
        if (trackers.isNotEmpty) {
          final newProgress = s.selectedEpisodeIndex + 1;
          for (final t in trackers) {
            if (newProgress > t.progress) {
              if (t.provider.toLowerCase() == 'anilist') {
                try {
                  final mediaId = int.tryParse(t.trackerId);
                  if (mediaId != null) {
                    await AniListProvider.editList(
                      mediaId: mediaId,
                      progress: newProgress,
                      status: AniListProvider.stringToMediaListStatus(t.status),
                    );
                    // Update local tracker
                    t.progress = newProgress;
                    await MiruGrpcClient.dbClient.upsertTracker(
                      proto.UpsertTrackerRequest()
                        ..package = history.package
                        ..detailUrl = history.detailUrl
                        ..tracker = t,
                    );
                  }
                } catch (error, stack) {
                  logger.warning('Failed to update tracking', error, stack);
                }
              }
            }
          }
        }
      }
    };
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
