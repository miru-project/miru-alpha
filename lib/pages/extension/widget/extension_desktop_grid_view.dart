import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/widgets/core/search_filter_card.dart';
import 'package:miru_alpha/pages/extension/widget/extension_tile.dart';
import 'package:miru_alpha/widgets/grid_view/index.dart';
import 'package:miru_alpha/pages/extension/widget/clearable_select.dart';

class ExtensionView extends HookConsumerWidget {
  const ExtensionView({
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
                              hintText: 'all'.i18n.toUpperCase(),
                              title: "type".i18n,
                              items: ['video'.i18n, 'manga'.i18n, 'novel'.i18n],
                              onChange: (val) {
                                if (val == 'video'.i18n) {
                                  val = 'bangumi';
                                } else if (val == 'manga'.i18n) {
                                  val = 'manga';
                                } else if (val == 'novel'.i18n) {
                                  val = 'fikushon';
                                } else {
                                  val = 'ALL';
                                }
                                extNotifier.filterByMediaType(val);
                                // ... wait, the logic needs to stay same for the notifier.
                                // I should keep the logic keys separate from display titles.
                                // But ClearableSelect labels depend on items.
                              },
                            ),
                            ClearableSelect(
                              // initialValue: 'ALL',
                              hintText: 'all'.i18n.toUpperCase(),
                              title: "extension.installed".i18n,
                              items: [
                                'all'.i18n.toUpperCase(),
                                'extension.installed'.i18n,
                                'extension.not_installed'.i18n
                              ],
                              onChange: (val) {
                                if (val == 'extension.installed'.i18n) {
                                  val = 'Installed';
                                } else if (val == 'extension.not_installed'.i18n) {
                                  val = 'Not Installed';
                                } else {
                                  val = 'ALL';
                                }
                                extNotifier.filterByInstalled(val);
                              },
                            ),
                            Row(
                              children: [
                                ClearableSelect(
                                  hintText: 'all'.i18n.toUpperCase(),
                                  title: "extension-repo.repository".i18n,
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
                                      return Text('extension-repo.reload'.i18n);
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
                                  'extension.search_extensions'.i18n,
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
                                hint: "extension.search_hint".i18n,
                                control: .managed(
                                  controller: textController,
                                  onChange: (value) {
                                    extNotifier.filterByName(value.text);
                                  },
                                ),
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
