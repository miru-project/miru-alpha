import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_track_page_provider.dart';
import 'package:miru_alpha/widgets/core/image_widget.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class AnilistProgressPage extends HookConsumerWidget {
  final AnilistProgressParam param;
  const AnilistProgressPage({super.key, required this.param});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anilistTrackPageProvider(param.mediaId));
    final notifier = ref.read(anilistTrackPageProvider(param.mediaId).notifier);

    Future<void> saveProgress() async {
      final success = await notifier.saveProgress(
        detailUrl: param.detailUrl,
        package: param.package,
        title: state.media?.title.userPreferred ?? 'unknown'.i18n,
      );
      if (context.mounted) {
        showSimpleToast(
          success
              ? 'anilist.progress_saved'.i18n
              : 'anilist.progress_save_failed'.i18n,
        );
        if (success) {
          context.pop();
        }
      }
    }

    Future<void> deleteEntry() async {
      final success = await notifier.deleteEntry();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'anilist.entry_deleted'.i18n
                  : 'anilist.entry_delete_failed'.i18n,
            ),
          ),
        );
        if (success) context.pop();
      }
    }

    void showSheet(String title, Widget child) {
      showFSheet(
        context: context,
        side: .btt,
        style: .delta(
          barrierFilter: (animation) => .compose(
            outer: ImageFilter.blur(
              sigmaX: animation * 5,
              sigmaY: animation * 5,
            ),
            inner: ColorFilter.mode(context.theme.colors.barrier, .srcOver),
          ),
        ),
        builder: (context) => SizedBox(
          height: 300,
          child: FTheme(
            data: ref.read(applicationControllerProvider).themeData,
            child: FScaffold(
              header: FHeader(title: Text(title)),
              child: child,
            ),
          ),
        ),
      );
    }

    void showPicker({
      required String title,
      required int count,
      required int initialIndex,
      required ValueChanged<int> onSelected,
      required String Function(int) labelBuilder,
    }) => showSheet(
      title,
      FPicker(
        control: .managed(
          initial: [initialIndex],
          onChange: (indexes) =>
              indexes.isNotEmpty ? onSelected(indexes.first) : null,
        ),
        children: [
          FPickerWheel(
            children: List.generate(
              count,
              (i) => Center(child: Text(labelBuilder(i))),
            ),
          ),
        ],
      ),
    );

    void showScorePicker() {
      final intPart = state.score.toInt();
      final decimalPart = ((state.score * 10).toInt() % 10);
      showSheet(
        'anilist.score'.i18n,
        FPicker(
          control: .managed(
            initial: [intPart, decimalPart],
            onChange: (indexes) => indexes.length >= 2
                ? notifier.setScore(indexes[0] + (indexes[1] / 10.0))
                : null,
          ),
          children: [
            FPickerWheel(
              flex: 3,
              children: List.generate(
                10,
                (i) => Center(child: Text(i.toString())),
              ),
            ),
            const Center(child: Text('.')),
            FPickerWheel(
              flex: 2,
              children: List.generate(
                10,
                (i) => Center(child: Text(i.toString())),
              ),
            ),
          ],
        ),
      );
    }

    return MiruScaffold(
      mobileHeader: SnapSheetNested.back(
        title: "anilist.tracking_progress".i18n,
      ),
      body: state.isLoading
          ? const Center(child: FCircularProgress.loader())
          : state.media == null
          ? const Center(child: Text('anilist.failed_load_media'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (state.media!.coverImage.large != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageWidget(
                              imageUrl: state.media!.coverImage.large!,
                              width: 60,
                              height: 90,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.media!.title.userPreferred ??
                                    'unknown'.i18n,
                                style: context.theme.typography.md.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  state.media!.status,
                                  if (state.media!.episodes != null)
                                    '${'anilist.total'.i18n}: ${state.media!.episodes} ${'episodes'.i18n}',
                                  if (state.media!.chapters != null)
                                    '${'anilist.total'.i18n}: ${state.media!.chapters} ${'chapters'.i18n}',
                                  if (state.media!.status == "RELEASING" &&
                                      state.media!.nextAiringEpisode != null)
                                    '${'anilist.aired'.i18n}: ${state.media!.nextAiringEpisode!.episode - 1}',
                                ].join(' • '),
                                style: TextStyle(
                                  color: context.theme.colors.mutedForeground,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FTileGroup(
                    children: [
                      FTile(
                        title: Text('status'.i18n),
                        subtitle: Text(
                          AniListProvider.mediaListStatusToTranslate(
                            state.status,
                            state.media!.type == "MANGA"
                                ? AnilistType.manga
                                : AnilistType.anime,
                          ),
                        ),
                        onPress: () => showPicker(
                          title: 'status'.i18n,
                          count: AnilistMediaListStatus.values.length,
                          initialIndex: AnilistMediaListStatus.values.indexOf(
                            state.status,
                          ),
                          onSelected: (index) => notifier.setStatus(
                            AnilistMediaListStatus.values[index],
                          ),
                          labelBuilder: (index) =>
                              AniListProvider.mediaListStatusToTranslate(
                                AnilistMediaListStatus.values[index],
                                state.media!.type == "MANGA"
                                    ? AnilistType.manga
                                    : AnilistType.anime,
                              ),
                        ),
                      ),
                      FTile(
                        title: Text('anilist.progress'.i18n),
                        subtitle: Text(
                          '${state.progress} / ${state.media!.episodes ?? state.media!.chapters ?? '?'}',
                        ),
                        onPress: () => showPicker(
                          title: 'anilist.progress'.i18n,
                          count:
                              (state.media!.episodes ??
                                  state.media!.chapters ??
                                  1000) +
                              1,
                          initialIndex: state.progress.toInt(),
                          onSelected: (index) => notifier.setProgress(index),
                          labelBuilder: (index) => index.toString(),
                        ),
                      ),
                      FTile(
                        title: Text('anilist.score'.i18n),
                        subtitle: Text(state.score.toString()),
                        onPress: showScorePicker,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FButton(
                            onPress: state.isSaving ? null : saveProgress,
                            child: state.isSaving
                                ? const FCircularProgress.loader()
                                : Text('anilist.save_progress'.i18n),
                          ),
                        ),
                        if (state.entry != null) ...[
                          const SizedBox(width: 12),
                          FButton.icon(
                            variant: .destructive,
                            onPress: state.isSaving ? null : deleteEntry,
                            child: const Icon(FIcons.trash2),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
