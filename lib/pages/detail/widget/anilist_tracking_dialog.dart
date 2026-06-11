import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_track_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/widgets/core/image_widget.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/widgets/dialog/dialog.dart';

class AnilistTrackingDialog extends HookConsumerWidget {
  final AnilistProgressParam param;
  final DetialProvider detailPr;
  final Animation<double> animation;
  final FDialogStyle style;

  const AnilistTrackingDialog({
    super.key,
    required this.param,
    required this.detailPr,
    required this.animation,
    required this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final state = ref.watch(anilistTrackPageProvider(param.mediaId));
    final isLoading = ref.watch(
      anilistTrackPageProvider(param.mediaId).select((e) => e.isLoading),
    );
    final media = ref.watch(
      anilistTrackPageProvider(param.mediaId).select((e) => e.media),
    );
    final score = ref.watch(
      anilistTrackPageProvider(param.mediaId).select((e) => e.score),
    );
    final progress = ref.watch(
      anilistTrackPageProvider(param.mediaId).select((e) => e.progress),
    );
    final status = ref.watch(
      anilistTrackPageProvider(param.mediaId).select((e) => e.status),
    );
    final isSaving = ref.watch(
      anilistTrackPageProvider(param.mediaId).select((e) => e.isSaving),
    );
    final entry = ref.watch(
      anilistTrackPageProvider(param.mediaId).select((e) => e.entry),
    );
    final notifier = ref.read(anilistTrackPageProvider(param.mediaId).notifier);
    final progressController = useTextEditingController(
      text: progress.toString(),
    );
    final scoreController = useTextEditingController(text: score.toString());

    useEffect(() {
      if (progressController.text != progress.toString()) {
        progressController.text = progress.toString();
      }
      return null;
    }, [progress]);

    useEffect(() {
      if (scoreController.text != score.toString()) {
        scoreController.text = score.toString();
      }
      return null;
    }, [score]);

    Future<void> saveProgress() async {
      final success = await notifier.saveProgress(
        detailUrl: param.detailUrl,
        package: param.package,
        title: media?.title.userPreferred ?? 'common.unknown'.i18n,
      );
      if (context.mounted) {
        showSimpleToast(
          success
              ? 'tracking.anilist.progress_saved'.i18n
              : 'tracking.anilist.progress_save_failed'.i18n,
        );
        if (success) {
          ref
              .read(detailPr.notifier)
              .fetchDetailInfo(param.package, param.detailUrl);
          Navigator.of(context).pop();
        }
      }
    }

    Future<void> unlinkTracker() async {
      final success = await notifier.unlinkTracker(
        detailUrl: param.detailUrl,
        package: param.package,
      );
      if (context.mounted) {
        showSimpleToast(
          success
              ? 'tracking.anilist.tracker_unlinked'.i18n
              : 'tracking.anilist.tracker_unlink_failed'.i18n,
        );
        if (success) {
          ref
              .read(detailPr.notifier)
              .fetchDetailInfo(param.package, param.detailUrl);
          Navigator.of(context).pop();
        }
      }
    }

    Future<void> showDeleteConfirmation() async {
      showMiruDialog(
        context: context,
        title: Text('common.warning'.i18n),
        body: Text(
          'tracking.anilist.delete_warning'.i18n.replaceAll(
            '{provider}',
            'AniList',
          ),
        ),
        actions: [
          FButton(
            variant: .destructive,
            onPress: () async {
              Navigator.of(context).pop();
              final success = await notifier.deleteEntry(
                detailUrl: param.detailUrl,
                package: param.package,
              );
              if (context.mounted) {
                showSimpleToast(
                  success
                      ? 'tracking.anilist.entry_deleted'.i18n
                      : 'tracking.anilist.entry_delete_failed'.i18n,
                );
                if (success) {
                  ref
                      .read(detailPr.notifier)
                      .fetchDetailInfo(param.package, param.detailUrl);
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text('common.delete'.i18n),
          ),
          FButton(
            variant: .ghost,
            onPress: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.i18n),
          ),
        ],
      );
    }

    if (isLoading) {
      return FDialog(
        style: style,
        animation: animation,
        actions: [
          FButton(
            variant: .ghost,
            onPress: () => Navigator.of(context).pop(),
            child: Text('common.close'.i18n),
          ),
        ],
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: FCircularProgress.loader(),
          ),
        ),
      );
    }

    if (media == null) {
      return FDialog(
        style: style,
        animation: animation,
        title: Text('tracking.anilist.tracking_progress'.i18n),
        body: Center(child: Text('tracking.anilist.failed_load_media'.i18n)),
        actions: [
          FButton(
            onPress: () => Navigator.of(context).pop(),
            child: Text('common.close'.i18n),
          ),
        ],
      );
    }

    return FDialog(
      style: style,
      animation: animation,
      body: SizedBox(
        width: 500,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (media.coverImage.large != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageWidget(
                        imageUrl: media.coverImage.large!,
                        width: 80,
                        height: 120,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media.title.userPreferred ?? 'common.unknown'.i18n,
                          style: context.theme.typography.lg.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          [
                            media.status,
                            if (media.episodes != null)
                              '${'tracking.anilist.total'.i18n}: ${media.episodes} ${'media.episodes'.i18n}',
                            if (media.chapters != null)
                              '${'tracking.anilist.total'.i18n}: ${media.chapters} ${'media.chapters'.i18n}',
                          ].join(' • '),
                          style: TextStyle(
                            color: context.theme.colors.mutedForeground,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const FDivider(),
              _buildSectionTitle(context, 'common.status'.i18n),
              const SizedBox(height: 8),
              FSelectTileGroup<AnilistMediaListStatus>.builder(
                count: AnilistMediaListStatus.values.length,
                control: FMultiValueControl.managedRadio(
                  initial: status,
                  onChange: (selected) {
                    if (selected.isNotEmpty) {
                      notifier.setStatus(selected.first);
                    }
                  },
                ),
                tileBuilder: (context, index) {
                  final status = AnilistMediaListStatus.values[index];
                  return FSelectTile(
                    value: status,
                    title: Text(
                      AniListProvider.mediaListStatusToTranslate(
                        status,
                        media.type == "MANGA"
                            ? AnilistType.manga
                            : AnilistType.anime,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          context,
                          'tracking.anilist.progress'.i18n,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FButton.icon(
                              variant: .outline,
                              onPress: () =>
                                  notifier.setProgress(progress.toInt() - 1),
                              child: const Icon(FLucideIcons.minus, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FTextField(
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                control: FTextFieldControl.managed(
                                  controller: progressController,
                                  onChange: (val) {
                                    final v = int.tryParse(val.text);
                                    if (v != null) notifier.setProgress(v);
                                  },
                                ),
                                keyboardType: TextInputType.number,
                                hint: '0',
                                suffixBuilder: (context, style, states) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    '/ ${media.episodes ?? media.chapters ?? "?"}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FButton.icon(
                              variant: .outline,
                              onPress: () =>
                                  notifier.setProgress(progress.toInt() + 1),
                              child: const Icon(FLucideIcons.plus, size: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          context,
                          'tracking.anilist.score'.i18n,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FButton.icon(
                              variant: .outline,
                              onPress: () => notifier.setScore(score - 0.5),
                              child: const Icon(FLucideIcons.minus, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FTextField(
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                control: FTextFieldControl.managed(
                                  controller: scoreController,
                                  onChange: (val) {
                                    final v = double.tryParse(val.text);
                                    if (v != null) notifier.setScore(v);
                                  },
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                hint: '0.0',
                                suffixBuilder: (context, style, states) =>
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Text(
                                        '/ 10.0',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FButton.icon(
                              variant: .outline,
                              onPress: () => notifier.setScore(score + 0.5),
                              child: const Icon(FLucideIcons.plus, size: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        FButton(
          prefix: Icon(FLucideIcons.save),
          onPress: isSaving ? null : saveProgress,
          child: isSaving
              ? const FCircularProgress.loader()
              : Text('tracking.anilist.save_progress'.i18n),
        ),
        if (param.isLinked)
          FButton(
            prefix: const Icon(FLucideIcons.unlink),
            variant: .secondary,
            onPress: isSaving ? null : unlinkTracker,
            child: Text('tracking.unlink'.i18n),
          ),
        if (entry != null)
          FButton(
            prefix: const Icon(FLucideIcons.trash),
            variant: .destructive,
            onPress: isSaving ? null : showDeleteConfirmation,
            child: Text('tracking.delete_entry'.i18n),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.theme.typography.sm.copyWith(
        fontWeight: FontWeight.w600,
        color: context.theme.colors.mutedForeground,
      ),
    );
  }
}
