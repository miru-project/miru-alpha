import 'dart:io';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/pages/extension/widget/extension_desktop_grid_view.dart';
import 'package:miru_alpha/pages/extension/widget/extension_tile.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/hook/sheet_controller.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:path/path.dart' as p;
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:miru_alpha/widgets/dialog/dialog.dart';
import '../../model/index.dart';

class ExtensionPage extends StatefulHookConsumerWidget {
  const ExtensionPage({super.key});
  @override
  createState() => _ExtensionPageState();
}

class CatEntry {
  final String title;
  final List<String> items;
  final void Function(String) onpress;
  final String? initialValue;
  const CatEntry({
    required this.title,
    required this.items,
    required this.onpress,
    this.initialValue,
  });
}

class _MobileExtensionModal extends HookConsumerWidget {
  const _MobileExtensionModal();
  static const categories = [
    'common.status',
    'common.type',
    'extension.repo.repository',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extNotifier = ref.read(extensionPageProvider.notifier);
    final catentry = <String, CatEntry>{
      'status': CatEntry(
        initialValue: 'ALL',
        title: 'Status',
        items: [
          'common.all',
          'extension.installed',
          'extension.not_installed',
          'extension.update_available',
        ],
        onpress: (val) {
          extNotifier.filterByInstalled(val);
        },
      ),
      'type': CatEntry(
        initialValue: 'ALL',
        title: 'Type',
        items: ['common.all', 'media.video', 'media.manga', 'media.novel'],
        onpress: (val) {
          switch (val) {
            case 'video':
              val = 'bangumi';
              break;
            case 'manga':
              val = 'manga';
              break;
            case 'novel':
              val = 'fikushon';
              break;
            default:
              val = 'ALL';
          }
          extNotifier.filterByMediaType(val);
        },
      ),
      'extension.repo.repository': CatEntry(
        title: 'Repository',
        items: extNotifier.getRepoNames(),
        onpress: (val) {
          extNotifier.filterByRepo(val);
        },
      ),
    };
    return FTabs(
      children: List.generate(categories.length, (index) {
        final entry = categories[index];
        return FTabEntry(
          label: Text(entry.i18n),
          child: CategoryGroup(
            items: catentry[entry]?.items ?? [],
            initialValue: catentry[entry]?.initialValue,
            onpress: catentry[entry]?.onpress ?? (String val) {},
          ),
        );
      }),
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
    final sheetController = useSheetController();
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        extNotifier.loadRepos();
      });
      return null;
    }, const []);

    return MiruScaffold(
      sheetController: sheetController,
      scrollController: scrollController,

      mobileHeader: Row(
        children: [
          SnapSheetHeader(title: 'extension.name'.i18n),
          const Spacer(),
          FButton.icon(
            variant: .ghost,
            onPress: () {
              String? editValue;
              showMiruDialog(
                context: context,
                title: Text('extension.import.title'.i18n),
                actions: [
                  FButton(
                    variant: .secondary,
                    onPress: () {
                      if (editValue == null) return;
                    },
                    child: Text('extension.import.import_by_url'.i18n),
                  ),
                  FButton(
                    onPress: () async {
                      Navigator.of(context).pop();
                      try {
                        final result = await FilePicker.pickFiles(
                          type: .custom,
                          allowedExtensions: ['js'],
                        );
                        if (result != null &&
                            result.files.single.path != null) {
                          final pickedPath = result.files.single.path!;
                          final filename = p.basename(pickedPath);
                          final reg = RegExp(r'^\w.+\.\w+\.js$');
                          if (!reg.hasMatch(filename)) {
                            showSimpleToast('Invalid extension name');
                            return;
                          }
                          final targetPath = p.join(
                            Core.extensionPath,
                            filename,
                          );
                          final targetDir = Directory(Core.extensionPath);
                          if (!targetDir.existsSync()) {
                            await targetDir.create(recursive: true);
                          }
                          await File(pickedPath).copy(targetPath);
                          showSimpleToast('Install Success');
                        }
                      } catch (e) {
                        showSimpleToast('Install Failed: $e');
                      }
                    },
                    child: Text('extension.import.import_by_local'.i18n),
                  ),
                ],
                body: Form(
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Text('extension.import.tips'.i18n),
                      SizedBox(height: 10),
                      FTextFormField(
                        autovalidateMode: .onUserInteraction,
                        validator: (value) =>
                            ((value?.startsWith('https') ?? false) ||
                                    (value?.startsWith('http') ?? false)) &&
                                (value?.endsWith('.js') ?? false)
                            ? null
                            : 'extension.import.invalid_url'.i18n,
                        hint: 'https://example.com/ext.js',
                        control: .managed(
                          onChange: (value) {
                            editValue = value.text;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Icon(FLucideIcons.plus, size: 24),
          ),
          SizedBox(width: 10),
        ],
      ),
      snapSheet: <Widget>[
        Padding(
          padding: .symmetric(horizontal: 10),
          child: FTextField(
            onTap: () {
              if (((sheetController.value ?? 190.0).toInt() - 190).abs() < 2) {
                sheetController.animateTo(
                  SheetOffset.proportionalToViewport(.5),
                );
              }
            },
            maxLines: 1,
            control: .managed(
              onChange: (value) {
                extNotifier.filterByName(value.text);
              },
            ),
            hint: "extension.search_hint".i18n,
            prefixBuilder: (context, style, states) => Padding(
              padding: EdgeInsetsGeometry.only(left: 12, right: 10),
              child: Icon(FLucideIcons.search),
            ),
          ),
        ),
        SizedBox(height: 10),
        _MobileExtensionModal(),
      ],
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
                desktopWidget: ExtensionView(
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
