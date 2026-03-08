import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_alpha/pages/download/mobile_download_page.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:forui/forui.dart';
import './widget/index.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/widgets/error.dart';
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

    return MiruScaffold(
      childPad: false,
      mobileHeader: _buildmobileHeader(context, ref, downloadPath),
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
            Text("download".i18n, style: context.theme.typography.xl2),
            FTooltip(
              tipBuilder: (context, controller) =>
                  Text("select_download_directory_tip".i18n),
              child: FButton.icon(
                onPress: () async {
                  String? result = await FilePicker.platform.getDirectoryPath();
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
              "${"path".i18n}: $downloadPath",
              style: context.theme.typography.sm.copyWith(
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
    final state = ref.watch(downloadProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          state.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (e, s) => ErrorDisplay.grpc(err: e, stack: s),
            data: (downloadState) {
              final activeTasks = downloadState.active;

              return Column(
                children: [
                  if (activeTasks.isNotEmpty)
                    FTileGroup.builder(
                      label: Text("active_tasks".i18n),
                      count: activeTasks.length,
                      tileBuilder: (context, index) =>
                          DownloadProcessTile(progress: activeTasks[index]),
                    ),
                  const SizedBox(height: 24),
                  FTileGroup.builder(
                    label: Text("downloads_history".i18n),
                    count: downloadState.history.length,
                    tileBuilder: (context, index) => DownloadHistoryTile(
                      download: downloadState.history[index],
                    ),
                  ),
                  if (downloadState.hasMore)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: FButton(
                          onPress: () => ref
                              .read(downloadProvider.notifier)
                              .loadMoreHistory(),
                          child: Text("load_more".i18n),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
