import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/search/global_search.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/utils/hook/sheet_controller.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/storage_index.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class MobileSearchPage extends HookConsumerWidget {
  const MobileSearchPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchPageProvider);
    final metaData = searchState.filteredMetaData;
    final pinnedExtensions = useState(
      MiruSettings.getSettingSync<Set<String>>(SettingKey.pinnedExtension),
    );
    final containedPinned = metaData.where((ext) {
      return pinnedExtensions.value.contains(ext.packageName);
    });
    final sheetController = useSheetController();
    final searchQuery = useState('');
    return MiruScaffold.mobile(
      sliverHeaders: [
        SimpleSliverHeaderDelegate(
          maxExtent: 56,
          child: SnapSheetHeader(title: 'common.search'.i18n),
        ),
      ],
      slivers: searchQuery.value.isEmpty
          ? [
              if (containedPinned.isNotEmpty)
                SliverToBoxAdapter(
                  child: FTileGroup(
                    label: Text('extension.pinned'.i18n),
                    children: containedPinned.map((ext) {
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
                      );
                    }).toList(),
                  ),
                ),
              if (metaData.isNotEmpty) ...[
                SliverList.separated(
                  separatorBuilder: (context, index) {
                    return FDivider(
                      style: .delta(padding: .value(.symmetric(vertical: 10))),
                    );
                  },
                  itemCount: metaData.length,
                  itemBuilder: (context, index) {
                    final ext = metaData[index];
                    final isPinned = pinnedExtensions.value.contains(
                      ext.packageName,
                    );
                    return FTappable(
                      style: .delta(motion: FTappableMotion.none),
                      onPress: () {
                        context.push(
                          '/search/single',
                          extra: SearchPageParam(meta: ext),
                        );
                      },
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: context.theme.colors.border.withAlpha(30),
                              child: SizedBox(
                                height: 48,
                                width: 48,
                                child: ImageWidget(imageUrl: ext.icon ?? ""),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ext.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      ext.version,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context
                                            .theme
                                            .colors
                                            .mutedForeground,
                                      ),
                                    ),
                                    if (ext.description?.isNotEmpty ??
                                        false) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          "•",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context
                                                .theme
                                                .colors
                                                .mutedForeground,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ext.description!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context
                                                .theme
                                                .colors
                                                .mutedForeground,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          FButton.icon(
                            variant: .ghost,
                            onPress: () {
                              context.push<ExtensionSettingParam>(
                                '/extensionSettings',
                                extra: ExtensionSettingParam(
                                  pkg: ext.packageName,
                                  name: ext.name,
                                ),
                              );
                            },
                            child: Icon(FLucideIcons.settings),
                          ),
                          FButton.icon(
                            variant: .ghost,
                            onPress: () {
                              final newSet = {...pinnedExtensions.value};
                              if (isPinned) {
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
                            child: Icon(
                              isPinned ? FLucideIcons.pinOff : FLucideIcons.pin,
                              size: 20,
                              color: isPinned
                                  ? context.theme.colors.primary
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'extension.no_extensions_installed'.i18n,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            ]
          : null,
      body: searchQuery.value.isNotEmpty
          ? GlobalSearch(searchQuery: searchQuery.value, isMobile: true)
          : null,
      snapSheet: [
        Padding(
          padding: .symmetric(horizontal: 10),
          child: FTextField(
            // onTapOutside: (event) {
            onTap: () {
              if (((sheetController.value ?? 190.0).toInt() - 190).abs() < 2) {
                sheetController.animateTo(
                  SheetOffset.proportionalToViewport(.5),
                  duration: const Duration(milliseconds: 150),
                );
              }
            },
            maxLines: 1,
            onSubmit: (value) {
              searchQuery.value = value;
            },
            control: .managed(
              onChange: (value) {
                if (value.text.isEmpty) {
                  searchQuery.value = value.text;
                }
              },
            ),
            clearable: (value) => value.text.isNotEmpty,
            // onTapOutside: (event) {
            //   FocusScope.of(context).unfocus();
            // },
            hint: "common.search_by_keywords".i18n,
            prefixBuilder: (context, style, states) => Padding(
              padding: EdgeInsetsGeometry.only(left: 12, right: 10),
              child: Icon(FLucideIcons.search),
            ),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: .symmetric(horizontal: 10),
          child: FTabs(
            children: [
              FTabEntry(
                label: Text('common.type'.i18n),
                child: CategoryMultiGroup(
                  items: ['bangumi', 'manga', 'novel'],
                  onpress: (val) {},
                ),
              ),
              FTabEntry(
                label: Text('common.language'.i18n),
                child: CategoryMultiGroup(items: ['WIP'], onpress: (val) {}),
              ),
              FTabEntry(
                label: Text('extension.name'.i18n),
                child: CategoryMultiGroup(items: ['WIP'], onpress: (val) {}),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
