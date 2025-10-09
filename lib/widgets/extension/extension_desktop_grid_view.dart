import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/widgets/search/search_filter_card.dart';
import 'package:miru_app_new/widgets/extension/extension_tile.dart';
import 'package:miru_app_new/widgets/gridView/index.dart';
import 'package:miru_app_new/widgets/extension/clearable_select.dart';

class ExtensionDesktopGridView extends HookConsumerWidget {
  const ExtensionDesktopGridView({
    super.key,
    required this.extensionsWithRepo,
    required this.constraints,
  });
  final List<Map<String, dynamic>> extensionsWithRepo;
  final BoxConstraints constraints;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final extNotifier = ref.read(extensionPageProvider.notifier);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: MiruGridView(
                  paddingHeightOffest: 60,
                  desktopGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: 210,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  mobileGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final pair = extensionsWithRepo[index];
                    final data = pair['ext'] as GithubExtension;
                    final repoUrl = pair['repoUrl'] as String;
                    return ExtensionTile(data: data, repoUrl: repoUrl);
                  },
                  itemCount: extensionsWithRepo.length,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 110,
            width: constraints.maxWidth - 30,
            child: SearchFilterCard(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            ClearableSelect(
                              hintText: 'ALL',
                              title: "Type",
                              items: ['Video', 'Manga', 'Novel'],
                              onChange: (val) {
                                switch (val) {
                                  case 'Video':
                                    val = 'bangumi';
                                    break;
                                  case 'Manga':
                                    val = 'manga';
                                    break;
                                  case 'Novel':
                                    val = 'fikushon';
                                    break;
                                  default:
                                    val = 'ALL';
                                }
                                extNotifier.filterByMediaType(val);
                              },
                            ),
                            ClearableSelect(
                              // initialValue: 'ALL',
                              hintText: 'ALL',
                              title: "Installed",
                              items: ['ALL', 'Installed', 'Not Installed'],
                              onChange: (val) {
                                extNotifier.filterByInstalled(val ?? 'ALL');
                              },
                            ),
                            Row(
                              children: [
                                ClearableSelect(
                                  hintText: 'ALL',
                                  title: "Repository",
                                  items: extNotifier.repoNames(),
                                  onChange: (val) {
                                    extNotifier.selectRepoByName(val ?? '');
                                  },
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: FTooltip(
                                    tipBuilder: (context, controller) {
                                      return const Text('Reload Repositories');
                                    },
                                    child: FButton.icon(
                                      onPress: () async {
                                        await extNotifier.reloadRepos();
                                      },
                                      child: const Icon(Icons.refresh),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 280,
                              height: 63,
                              child: FTextField(
                                // style: FTextFieldStyle.inherit(
                                //   colors: context.theme.colors,
                                //   typography:
                                //       overrideTheme.typography,
                                //   style: overrideTheme.style,
                                // ).call,
                                label: Text(
                                  'Search extensions ',
                                  style: TextStyle(fontSize: 14),
                                ),

                                clearable: (value) => value.text.isNotEmpty,
                                prefixBuilder: (context, style, states) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      right: 5,
                                    ),
                                    child: Icon(FIcons.search, size: 16),
                                  );
                                },
                                hint: "Search by Name or Tags ...",
                                controller: textController,
                                onChange: (val) {
                                  extNotifier.filterByName(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
