import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/utils/store/storage_index.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';
import 'package:miru_app_new/widgets/scaffold/miru_scaffold.dart';
import 'package:miru_app_new/widgets/scaffold/snapsheet_header.dart';

class MobileSearchPage extends HookConsumerWidget {
  const MobileSearchPage({super.key});
  static const _categories = ['Type', 'Language', 'Extension'];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaData = ref.watch(extensionPageProvider).metaData;
    final pinnedExtensions = useState(
      MiruSettings.getSettingSync<Set<String>>(SettingKey.pinnedExtension),
    );
    final containedPinned = metaData.where((ext) {
      return pinnedExtensions.value.contains(ext.packageName);
    });

    return MiruScaffold(
      mobileHeader: const SnapSheetHeader(title: 'Seach'),
      snapSheet: [
        FTextField(
          maxLines: 1,
          control: .managed(
            onChange: (value) {
              // extNotifier.filterByName(value.text);
            },
          ),
          hint: "Search by Name or Tags ...",
          prefixBuilder: (context, style, states) => Padding(
            padding: EdgeInsetsGeometry.only(left: 12, right: 10),
            child: Icon(FIcons.search),
          ),
        ),
        SizedBox(height: 10),
        FTabs(
          children: List.generate(
            _categories.length,
            (index) => FTabEntry(
              label: Text(_categories[index]),
              child: Placeholder(),
            ),
          ),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          // SliverToBoxAdapter(child: SizedBox(height: 150)),
          if (containedPinned.isNotEmpty)
            SliverToBoxAdapter(
              child: FTileGroup(
                label: Text('Pinned'),
                description: Text('Pinned extensions '),
                children: List.generate(containedPinned.length, (index) {
                  {
                    final ext = containedPinned.elementAt(index);

                    return FTile(
                      onPress: () {
                        context.push(
                          '/search/single',
                          extra: SearchPageParam(meta: ext),
                        );
                      },
                      title: Text(ext.name),
                      prefix: SizedBox(
                        height: 40,
                        width: 40,
                        child: ImageWidget(imageUrl: ext.icon ?? ""),
                      ),
                      suffix: FButton.icon(
                        selected: true,
                        onPress: () {
                          final newSet = {...pinnedExtensions.value};
                          if (newSet.contains(ext.packageName)) {
                            newSet.remove(ext.packageName);
                          } else {
                            newSet.add(ext.packageName);
                          }
                          pinnedExtensions.value = newSet;
                          MiruSettings.setSettingSync(
                            SettingKey.pinnedExtension,
                            newSet.toString(),
                          );
                        },
                        child: pinnedExtensions.value.contains(ext.packageName)
                            ? Icon(FIcons.pinOff)
                            : Icon(FIcons.pin),
                      ),
                    );
                  }
                }),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 20)),
          if (metaData.isNotEmpty)
            SliverToBoxAdapter(
              child: FTileGroup(
                label: Text('Extension'),
                description: Text('Extensions that already installed'),
                children: List.generate(metaData.length, (index) {
                  final ext = metaData[index];
                  return FTile(
                    onPress: () {
                      context.push(
                        '/search/single',
                        extra: SearchPageParam(meta: ext),
                      );
                    },
                    title: Text(ext.name),
                    prefix: SizedBox(
                      height: 40,
                      width: 40,
                      child: ImageWidget(imageUrl: ext.icon ?? ""),
                    ),
                    suffix: FButton.icon(
                      selected: true,
                      onPress: () {
                        final newSet = {...pinnedExtensions.value};
                        if (newSet.contains(ext.packageName)) {
                          newSet.remove(ext.packageName);
                        } else {
                          newSet.add(ext.packageName);
                        }
                        pinnedExtensions.value = newSet;
                        MiruSettings.setSettingSync(
                          SettingKey.pinnedExtension,
                          newSet.toString(),
                        );
                      },
                      child: pinnedExtensions.value.contains(ext.packageName)
                          ? Icon(FIcons.pinOff)
                          : Icon(FIcons.pin),
                    ),
                  );
                }),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'No extensions installed',
                  style: TextStyle(fontWeight: .bold, fontSize: 20),
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 200)),
        ],
      ),
    );
  }
}
