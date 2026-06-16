import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/pages/setting/widget/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';

class MangaPageSetting extends ConsumerWidget {
  const MangaPageSetting({super.key, required this.mangaProvider});
  final MangaReaderProvider mangaProvider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FTileGroup(
      label: Text('reader.manga.page_settings.name'.i18n),
      children: [
        SettingsRadiosTile.detailed(
          isMobileLayout: true,
          title: 'reader.manga.read_mode.name',
          subtitle: 'reader.manga.read_mode.information',
          entry: MangaReadMode.values
              .map(
                (e) => RadioTileEntry(
                  value: e.name,
                  title: 'reader.manga.read_mode.${e.name}',
                ),
              )
              .toList(),
          value: MiruSettings.getSettingSync(SettingKey.mangaReadingMode),
          onChanged: (val) {
            MiruSettings.setSetting(SettingKey.mangaReadingMode, val);
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
