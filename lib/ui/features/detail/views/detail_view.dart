import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/detail/view_models/detail_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

class DetailView extends HookConsumerWidget {
  const DetailView({super.key, required this.meta, required this.detailUrl});

  final ExtensionMeta meta;
  final String detailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(
      detailViewModelProvider(meta.packageName, detailUrl),
    );
    final notifier = ref.read(
      detailViewModelProvider(meta.packageName, detailUrl).notifier,
    );
    final isRefreshing = useState(false);

    return MiruScaffold.mobile(
      sliverHeaders: [
        FlexibleHeaderDelegate(
          scrollPosition: useValueNotifier(0.0),
          maxExtent: 180,
          minExtent: 120,
          builder: (context, shrinkOffset, shrinkProgress) {
            final detail = viewModelAsync.value;
            return SnapSheetHeader(
              title: detail?.title ?? 'detail.loading'.i18n,
              description: detail?.desc,
              suffix: [
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  onPress: () async {
                    isRefreshing.value = true;
                    await notifier.refresh();
                    isRefreshing.value = false;
                  },
                  child: isRefreshing.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: FCircularProgress(),
                        )
                      : const Icon(FLucideIcons.refreshCw),
                ),
              ],
            );
          },
        ),
      ],
      body: viewModelAsync.when(
        loading: () => const LoadingState(),
        error: (error, stack) => ErrorState(
          message: 'detail.load_failed'.i18n,
          onRetry: notifier.refresh,
          retryLabel: 'common.retry'.i18n,
        ),
        data: (detail) {
          if (detail == null) {
            return const Center(child: FCircularProgress());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (detail.cover != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      detail.cover!,
                      width: 160,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                detail.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                detail.detailUrl,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (detail.desc != null)
                Text(
                  detail.desc!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(height: 24),
              if (detail.episodes != null) ...[
                for (
                  var groupIndex = 0;
                  groupIndex < detail.episodes!.length;
                  groupIndex++
                )
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.episodes![groupIndex].name ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: detail.episodes![groupIndex].episodes
                            .asMap()
                            .entries
                            .map(
                              (entry) => FButton(
                                variant: FButtonVariant.outline,
                                onPress: () {
                                  final epGroup = detail.episodes!
                                      .map(
                                        (g) => ExtensionEpisodeGroup(
                                          title: g.name,
                                          urls: g.episodes
                                              .map(
                                                (e) => ExtensionEpisode(
                                                  name: e.name,
                                                  url: e.url,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      )
                                      .toList();
                                  context.push<WatchParams>(
                                    '/watch',
                                    extra: WatchParams(
                                      meta: meta,
                                      type: meta.type,
                                      url: entry.value.url,
                                      selectedGroupIndex: groupIndex,
                                      selectedEpisodeIndex: entry.key,
                                      name: detail.title,
                                      detailImageUrl: detail.cover ?? '',
                                      detailUrl: detail.detailUrl,
                                      epGroup: epGroup,
                                      savePath: null,
                                    ),
                                  );
                                },
                                child: Text(entry.value.name ?? ''),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
