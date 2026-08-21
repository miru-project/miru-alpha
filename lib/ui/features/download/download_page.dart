import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/ui/features/download/mobile_download_page.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:forui/forui.dart';
import './widget/index.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';

class DownloadPage extends ConsumerWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadPath = ref.watch(
      applicationControllerProvider.select(
        (v) => MiruSettings.getSettingSync<String>(SettingKey.downloadPath),
      ),
    );

    return MiruScaffold.mobile(
      childPad: false,
      sliverHeaders: [
        SimpleSliverHeaderDelegate(
          maxExtent: 110,
          child: _buildmobileHeader(context, ref, downloadPath),
        ),
      ],
      body: const PlatformWidget(
        mobileWidget: MobileDownloadPage(),
        desktopWidget: DownloadPageDesktopLayout(),
      ),
    );
  }

  Widget _buildmobileHeader(
    BuildContext context,
    WidgetRef ref,
    String downloadPath,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "common.download".i18n,
              style: context.theme.typography.body.xl2,
            ),
            FTooltip(
              tipBuilder: (context, controller) =>
                  Text("settings.select_download_directory_tip".i18n),
              child: FButton.icon(
                onPress: () async {
                  String? result = await FilePicker.getDirectoryPath();
                  if (result != null) {
                    MiruSettings.setSettingSync(
                      SettingKey.downloadPath,
                      result,
                    );
                  }
                },
                child: const Icon(Icons.folder_open),
              ),
            ),
          ],
        ),
        if (downloadPath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "${"common.path".i18n}: $downloadPath",
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class DownloadPageDesktopLayout extends ConsumerWidget {
  const DownloadPageDesktopLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadPath = ref.watch(
      applicationControllerProvider.select(
        (v) => MiruSettings.getSettingSync<String>(SettingKey.downloadPath),
      ),
    );
    final state = ref.watch(downloadProvider);
    final notifier = ref.read(downloadProvider.notifier);
    final currentMax = notifier.maxConcurrent;

    return state.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (e, s) => Center(
        child: ErrorDisplay.grpc(
          err: e,
          stack: s,
          onRefresh: () {
            ref.invalidate(downloadProvider);
            ref.read(downloadProvider);
          },
        ),
      ),
      data: (downloadState) {
        final activeTasks = downloadState.active;
        final history = downloadState.history;

        return CustomScrollView(
          slivers: [
            // -- Pinned "Download" header
            SliverPersistentHeader(
              pinned: true,
              delegate: SimpleSliverHeaderDelegate(
                maxExtent: 64,
                minExtent: 64,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  decoration: BoxDecoration(
                    color: context.theme.colors.background,
                    border: Border(
                      bottom: BorderSide(color: context.theme.colors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'common.download'.i18n,
                        style: context.theme.typography.body.xl2,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FButton.icon(
                            variant: FButtonVariant.ghost,
                            onPress: () =>
                                context.push('/home/download/history'),
                            child: const Icon(FLucideIcons.clock),
                          ),
                          const SizedBox(width: 8),
                          FTooltip(
                            tipBuilder: (context, controller) => Text(
                              'settings.select_download_directory_tip'.i18n,
                            ),
                            child: FButton.icon(
                              onPress: () async {
                                final result =
                                    await FilePicker.getDirectoryPath();
                                if (result != null) {
                                  MiruSettings.setSettingSync(
                                    SettingKey.downloadPath,
                                    result,
                                  );
                                }
                              },
                              child: const Icon(FLucideIcons.folderOpen),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FButton.icon(
                            onPress: downloadPath.isEmpty
                                ? null
                                : () => openDownloadFile(downloadPath),
                            child: const Icon(FLucideIcons.folderOpen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // -- Settings row
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (downloadPath.isNotEmpty)
                      Text(
                        "${'common.path'.i18n}: $downloadPath",
                        style: context.theme.typography.body.sm.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'download.max_concurrent'.i18n,
                          style: context.theme.typography.body.sm,
                        ),
                        const SizedBox(width: 12),
                        FButton.icon(
                          onPress: currentMax <= 1
                              ? null
                              : () => notifier.setMaxConcurrent(currentMax - 1),
                          child: const Icon(FLucideIcons.minus),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: 24,
                            child: Text(
                              currentMax.toString(),
                              textAlign: TextAlign.center,
                              style: context.theme.typography.body.sm,
                            ),
                          ),
                        ),
                        FButton.icon(
                          onPress: currentMax >= 32
                              ? null
                              : () => notifier.setMaxConcurrent(currentMax + 1),
                          child: const Icon(FLucideIcons.plus),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // -- Active Tasks
            if (activeTasks.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "common.active_tasks".i18n,
                    style: context.theme.typography.body.lg,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    onReorderItem: (key, nextKey) {
                      final oldId = (key as ValueKey<int>).value;
                      final newId = (nextKey as ValueKey<int>?)?.value;
                      final tasks = [...activeTasks];
                      final oldIndex = tasks.indexWhere(
                        (t) => t.taskId == oldId,
                      );
                      final newIndex = newId == null
                          ? tasks.length - 1
                          : tasks.indexWhere((t) => t.taskId == newId);
                      if (oldIndex < 0 || newIndex < 0) return;
                      final moved = tasks.removeAt(oldIndex);
                      tasks.insert(newIndex, moved);
                      ref
                          .read(downloadProvider.notifier)
                          .reorderActive(tasks.map((t) => t.taskId).toList());
                    },
                    children: [
                      for (final task in activeTasks)
                        ReorderableDelayedDragStartListener(
                          key: ValueKey(task.taskId),
                          index: activeTasks.indexOf(task),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DownloadProcessTile(progress: task),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
            // -- History
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'common.history'.i18n,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            if (history.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: EmptyState(
                      icon: FLucideIcons.clock,
                      message: 'download.no_download_history'.i18n,
                    ),
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      DownloadHistoryTile(download: history[index]),
                ),
              ),
              if (downloadState.hasMore)
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: FButton(
                        onPress: () => ref
                            .read(downloadProvider.notifier)
                            .loadMoreHistory(),
                        child: Text("common.load_more".i18n),
                      ),
                    ),
                  ),
                ),
            ],
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        );
      },
    );
  }
}

class DesktopFinishedDownloadSection extends ConsumerWidget {
  const DesktopFinishedDownloadSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.theme.colors.border, width: 1),
            ),
          ),
          child: Text(
            "download.downloads_history".i18n,
            style: context.theme.typography.body.xl2,
          ),
        ),
        Expanded(
          child: state.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (e, s) => Center(
              child: ErrorDisplay.grpc(err: e, stack: s),
            ),
            data: (data) {
              final history = data.history;
              if (history.isEmpty) {
                return Center(
                  child: EmptyState(
                    icon: FLucideIcons.clock,
                    message: 'download.no_download_history'.i18n,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    DownloadHistoryTile(download: history[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
