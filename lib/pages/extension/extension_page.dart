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
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:path/path.dart' as p;
import 'package:miru_alpha/widgets/dialog/dialog.dart';
import '../../model/index.dart';

class ExtensionPage extends StatefulHookConsumerWidget {
  const ExtensionPage({super.key});
  @override
  createState() => _ExtensionPageState();
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

    return MiruScaffold.mobile(
      onHeaderScroll: (context, header, scrollOffset, headerHeight) {
        final progress = (scrollOffset / headerHeight).clamp(0.0, 1.0);
        return SizedBox(
          height: headerHeight - scrollOffset,
          child: Transform.scale(
            scale: 1 - progress * 0.3,
            child: Opacity(opacity: 1 - progress, child: header),
          ),
        );
      },
      scrollController: scrollController,
      // Empty snapSheet triggers non-snapSheet mode
      snapSheet: const [],
      mobileHeader: SnapSheetHeader(
        title: 'extension.name'.i18n,
        suffix: [
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
        ],
      ),
      // Pinned search bar + filter row
      mobilePinnedHeader: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FTextField(
            maxLines: 1,
            control: .managed(
              onChange: (value) {
                extNotifier.filterByName(value.text);
              },
            ),
            hint: "extension.search_hint".i18n,
            prefixBuilder: (context, style, states) => Padding(
              padding: const EdgeInsets.only(left: 12, right: 10),
              child: Icon(FLucideIcons.search),
            ),
          ),
          const SizedBox(height: 10),
          _ExtensionFilterBar(extNotifier: extNotifier),
        ],
      ),
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
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemBuilder: (context, index) {
                      final pair = extensionsWithRepo[index];
                      final data = pair['ext'] as GithubExtension;
                      final repoUrl = pair['repoUrl'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ExtensionTile(data: data, repoUrl: repoUrl),
                      );
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

class _ExtensionFilterBar extends HookConsumerWidget {
  const _ExtensionFilterBar({required this.extNotifier});

  final ExtensionPageNotifier extNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: FButton(
            variant: .outline,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            prefix: Icon(FLucideIcons.listFilter),
            suffix: AnimatedRotation(
              turns: expanded.value ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(FLucideIcons.chevronDown, size: 18),
            ),
            onPress: () {
              if (expanded.value) {
                controller.reverse();
              } else {
                controller.forward();
              }
              expanded.value = !expanded.value;
            },
            child: Expanded(
              child: Padding(
                padding: .symmetric(horizontal: 10),
                child: Text('common.filters'.i18n),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: expanded.value
              ? Padding(
                  padding: .only(top: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: FSelect<String>.rich(
                          label: Text('common.type'.i18n),
                          hint: 'common.all'.i18n,
                          control: FSelectManagedControl<String>(
                            onChange: (val) {
                              final v = val;
                              switch (v) {
                                case 'media.video':
                                  extNotifier.filterByMediaType('bangumi');
                                  break;
                                case 'media.manga':
                                  extNotifier.filterByMediaType('manga');
                                  break;
                                case 'media.novel':
                                  extNotifier.filterByMediaType('fikushon');
                                  break;
                                default:
                                  extNotifier.filterByMediaType('ALL');
                              }
                            },
                          ),
                          children: [
                            FSelectItem<String>(
                              value: 'common.all',
                              title: Text('common.all'.i18n),
                            ),
                            FSelectItem<String>(
                              value: 'media.video',
                              title: Text('media.video'.i18n),
                            ),
                            FSelectItem<String>(
                              value: 'media.manga',
                              title: Text('media.manga'.i18n),
                            ),
                            FSelectItem<String>(
                              value: 'media.novel',
                              title: Text('media.novel'.i18n),
                            ),
                          ],
                          format: (value) => value.i18n,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 180,
                        child: FSelect<String>.rich(
                          label: Text('extension.repo.repository'.i18n),
                          hint: 'common.all'.i18n,
                          control: FSelectManagedControl<String>(
                            onChange: (val) {
                              final v = val;
                              extNotifier.filterRepoByName(
                                v == 'common.all' ? '' : v ?? '',
                              );
                            },
                          ),
                          children: [
                            FSelectItem<String>(
                              value: 'common.all',
                              title: Text('common.all'.i18n),
                            ),
                            ...extNotifier.getRepoNames().map(
                              (e) => FSelectItem<String>(
                                value: e,
                                title: Text(e.i18n),
                              ),
                            ),
                          ],
                          format: (value) => value.i18n,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

enum CheckBoxInstalled { installed, notInstalled }
