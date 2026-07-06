import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/domain/models/download.dart';
import 'package:miru_alpha/ui/features/download/view_models/download_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

Future<void> _openDownloadFolder() async {
  final downloadPath = MiruSettings.getSettingSync<String>(
    SettingKey.downloadPath,
  );
  if (downloadPath.isEmpty) return;

  try {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', [downloadPath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [downloadPath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [downloadPath]);
    }
  } catch (e) {
    // Silently fail if unable to open folder
  }
}

class DownloadView extends HookConsumerWidget {
  const DownloadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(downloadViewModelProvider);

    return MiruScaffold.mobile(
      sliverHeaders: [
        FlexibleHeaderDelegate(
          scrollPosition: useValueNotifier(0.0),
          maxExtent: 180,
          minExtent: 120,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SnapSheetHeader(
              title: 'download.title'.i18n,
              suffix: [
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  onPress: () async {
                    await _openDownloadFolder();
                  },
                  child: const Icon(FLucideIcons.folderOpen),
                ),
              ],
            );
          },
        ),
      ],
      body: viewModelAsync.when(
        loading: () => const LoadingState(),
        error: (error, stack) =>
            ErrorState(message: 'download.load_failed'.i18n),
        data: (downloads) {
          if (downloads.isEmpty) {
            return EmptyState(
              icon: FLucideIcons.download,
              message: 'download.empty'.i18n,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(FLucideIcons.fileText),
                  title: Text(download.title),
                  subtitle: Text(download.status.label),
                  trailing: download.status == DownloadStatus.downloading
                      ? SizedBox(
                          width: 60,
                          child: LinearProgressIndicator(
                            value: download.progress,
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
