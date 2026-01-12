import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/pages/extension/widget/extension_desktop_grid_view.dart';
import 'package:miru_app_new/pages/extension/widget/extension_tile.dart';
import 'package:miru_app_new/widgets/index.dart';

import 'package:snapping_sheet_2/snapping_sheet.dart';
import '../../model/index.dart';

final SnappingSheetController _snappingController = SnappingSheetController();

class ExtensionPage extends StatefulHookConsumerWidget {
  const ExtensionPage({super.key});
  @override
  createState() => _ExtensionPageState();
}

class CatEntry {
  final String title;
  final List<String> items;
  final void Function(String) onpress;
  const CatEntry({
    required this.title,
    required this.items,
    required this.onpress,
  });
}

class _MobileExtensionModal extends HookConsumerWidget {
  const _MobileExtensionModal();
  static const categories = ['Status', 'Type', 'Repo'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extNotifier = ref.read(extensionPageProvider.notifier);
    final catentry = <String, CatEntry>{
      'Status': CatEntry(
        title: 'Status',
        items: ['ALL', 'Installed', 'Not installed'],
        onpress: (val) {
          extNotifier.filterByInstalled(val);
        },
      ),
      'Type': CatEntry(
        title: 'Type',
        items: ['ALL', 'Video', 'Manga', 'Novel'],
        onpress: (val) {
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
      'Repo': CatEntry(
        title: 'Repository',
        items: extNotifier.repoNames(),
        onpress: (val) {
          extNotifier.filterByRepo(val);
        },
      ),
    };
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        logger.info(_snappingController.currentPosition.toString());
        if (_snappingController.currentPosition < 200) {
          _snappingController.setSnappingSheetPosition(400);
        }
      },
      child: FTabs(
        children: List.generate(categories.length, (index) {
          final entry = categories[index];
          return FTabEntry(
            label: Text(entry),
            child: CategoryGroup(
              items: catentry[entry]?.items ?? [],
              onpress: catentry[entry]?.onpress ?? (String val) {},
            ),
          );
        }),
      ),
    );
  }
}

class _ExtensionPageState extends ConsumerState<ExtensionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final extState = ref.watch(extensionPageProvider.select((r) => r.loading));
    final extNotifier = ref.read(extensionPageProvider.notifier);

    final scrollController = useScrollController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        extNotifier.loadRepos();
      });
      return null;
    }, const []);

    return MiruScaffold(
      scrollController: scrollController,
      snappingSheetController: _snappingController,
      mobileHeader: SnapSheetHeader(
        title: 'Extension',
        trailings: [
          FButton.icon(
            style: FButtonStyle.ghost(),
            onPress: () {},
            child: Icon(FIcons.earth),
          ),
        ],
      ),
      snapSheet: DeviceUtil.isMobileLayout(context)
          ? <Widget>[
              FCard.raw(
                child: FTextField(
                  maxLines: 1,
                  control: .managed(
                    onChange: (value) {
                      extNotifier.filterByName(value.text);
                    },
                  ),
                  hint: "Search by Name or Tags ...",
                  prefixBuilder: (context, style, states) => Padding(
                    padding: EdgeInsetsGeometry.only(left: 12, right: 10),
                    child: Icon(FIcons.search),
                  ),
                ),
              ),
              SizedBox(height: 10),
              _MobileExtensionModal(),
            ]
          : <Widget>[],
      body: Consumer(
        builder: (context, ref, child) {
          final extensionList = ref.watch(
            extensionPageProvider.select((s) => s.extensionList),
          );
          return LayoutBuilder(
            builder: (context, constraints) {
              if (extState) {
                return const Center(child: FCircularProgress());
              }

              // Build flat list preserving repo url and name for each extension
              final extensionsWithRepo = <Map<String, dynamic>>[];
              for (final repoItem in extensionList) {
                for (final e in repoItem.extensions) {
                  extensionsWithRepo.add({
                    'ext': e,
                    'repoUrl': repoItem.url,
                    'repoName': repoItem.name,
                  });
                }
              }

              return PlatformWidget(
                desktopWidget: ExtensionDesktopGridView(
                  extensionsWithRepo: extensionsWithRepo,
                  constraints: constraints,
                ),
                mobileWidget: EasyRefresh(
                  header: const ForuiHeader(),
                  scrollController: scrollController,
                  onRefresh: () async {
                    await extNotifier.reloadRepos();
                  },
                  child: MiruListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      final pair = extensionsWithRepo[index];
                      final data = pair['ext'] as GithubExtension;
                      final repoUrl = pair['repoUrl'] as String;
                      return ExtensionTile(data: data, repoUrl: repoUrl);
                    },
                    itemCount: extensionsWithRepo.length,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

enum CheckBoxInstalled { installed, notInstalled }
