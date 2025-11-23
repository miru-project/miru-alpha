import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/pages/setting/widget/index.dart';
import 'package:miru_app_new/provider/watch/manga_reader_provider.dart';
import 'package:miru_app_new/utils/setting_dir_index.dart';

class MangaSettingGeneral extends ConsumerWidget {
  const MangaSettingGeneral({super.key, required this.mangaProvider});
  final MangaReaderProvider mangaProvider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FTileGroup(
      children: [
        SettingsRadiosTile(
          isMobileLayout: true,
          title: 'ReadMode',
          subtitle: 'ReadMode',
          radios: MangaReadMode.values.map((e) => e.name).toList(),
          value: MiruSettings.getSettingSync(SettingKey.readingMode),
          onChanged: (val) {
            MiruSettings.setSetting(SettingKey.readingMode, val);
            ref
                .read(mangaProvider.notifier)
                .changeReadMode(
                  MangaReadMode.values.firstWhere((e) => e.name == val),
                );
          },
        ),
      ],
    );
  }
}
