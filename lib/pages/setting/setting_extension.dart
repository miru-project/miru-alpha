import 'dart:ui';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/setting_page_provider.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/widgets/core/outter_card.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:miru_alpha/widgets/core/seperator.dart';

class MobileRepoDialog extends HookConsumerWidget {
  const MobileRepoDialog({
    super.key,
    required this.style,
    required this.animation,
  });
  final FDialogStyle Function(FDialogStyle)? style;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useState('');
    final url = useState('');
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: FDialog(
        style: .delta(),
        animation: animation,
        direction: Axis.horizontal,
        title: Text('extension-repo.add_repo'.i18n, style: TextStyle(fontSize: 25)),
        body: Padding(
          padding: EdgeInsetsGeometry.only(top: 20, bottom: 10),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FTextFormField(
                  label: Text('name'.i18n),
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(text: name.value),
                    onChange: (value) => name.value = value.text,
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  hint: 'extension-repo.official_repo'.i18n,
                  validator: (val) =>
                      (val?.isEmpty ?? false) ? 'extension-repo.name_cannot_be_empty'.i18n : null,
                ),
                SizedBox(height: 10),
                FTextFormField(
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(text: url.value),
                    onChange: (value) => url.value = value.text,
                  ),
                  label: Text('extension-repo.url'.i18n),
                  hint: 'https://miru-repo.0n0.dev/index.json',
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) => (value?.contains('.json') ?? false)
                      ? null
                      : 'extension-repo.url_validation_error'.i18n,
                ),
              ],
            ),
          ),
        ),
        actions: [
          FButton(
            onPress: (name.value.isEmpty && !url.value.contains('.json'))
                ? null
                : () async {
                    await MiruCoreEndpoint.setRepo(url.value, name.value);
                    ref.invalidate(extensionRepoProvider);
                    ref.read(extensionRepoProvider.future);
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                  },
            child: Text('save'.i18n),
          ),
          FButton(
            variant: .outline,
            onPress: () => Navigator.of(context).pop(),
            child: Text('cancel'.i18n),
          ),
        ],
      ),
    );
  }
}

class RepoDialog extends HookConsumerWidget {
  const RepoDialog({super.key, required this.style, required this.animation});
  final FDialogStyleDelta style;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useState('');
    final url = useState('');
    return FDialog(
      style: style,
      animation: animation,
      direction: Axis.horizontal,
      title: Text('extension-repo.add_repo'.i18n),
      body: Form(
        child: Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Column(
            children: [
              FTextFormField(
                control: FTextFieldControl.managed(
                  initial: TextEditingValue(text: name.value),
                  onChange: (value) => name.value = value.text,
                ),
                label: Text('name'.i18n),
                autovalidateMode: AutovalidateMode.always,
                hint: 'extension-repo.official_repo'.i18n,
                validator: (val) =>
                    (val?.isEmpty ?? false) ? 'extension-repo.name_cannot_be_empty'.i18n : null,
              ),
              const SizedBox(height: 10),
              FTextFormField(
                control: FTextFieldControl.managed(
                  initial: TextEditingValue(text: url.value),
                  onChange: (value) => url.value = value.text,
                ),
                label: Text('extension-repo.url'.i18n),
                hint: 'https://miru-repo.0n0.dev/index.json',
                autovalidateMode: AutovalidateMode.always,
                validator: (value) => (value?.contains('.json') ?? false)
                    ? null
                    : 'extension-repo.url_validation_error'.i18n,
              ),
            ],
          ),
        ),
      ),
      actions: [
        FButton(
          onPress: (name.value.isEmpty && !url.value.contains('.json'))
              ? null
              : () async {
                  await MiruCoreEndpoint.setRepo(url.value, name.value);
                  ref.invalidate(extensionRepoProvider);
                  ref.read(extensionRepoProvider.future);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                },
          child: Text('save'.i18n),
        ),
        FButton(
          variant: .outline,
          onPress: () => Navigator.of(context).pop(),
          child: Text('cancel'.i18n),
        ),
      ],
    );
  }
}

class SettingExtension extends HookConsumerWidget {
  const SettingExtension({super.key, this.isMobile = false});
  final bool isMobile;
  List<Widget> buildRepoSetting(
    ValueNotifier<bool> selectAll,
    ValueNotifier<Set<String>> selected,
    List<RepoConfig> repos,
  ) {
    return repos.map((repo) {
      final name = repo.name;
      final url = repo.link;
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                child: FCheckbox(
                  value: selectAll.value || selected.value.contains(url),
                  label: const Text(""),
                  onChange: (v) {
                    logger.info('Checkbox changed: $v for $url');
                    if (v) {
                      selected.value = Set.from(selected.value)..add(url);
                    } else {
                      selected.value = Set.from(selected.value)..remove(url);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(name, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(url, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      );
    }).toList();
  }

  void showRepoRemoveDialog(
    BuildContext context,
    WidgetRef ref,
    Set<String> selected,
  ) {
    showFDialog(
      routeStyle: .delta(
        barrierFilter: () =>
            (animation) => ImageFilter.compose(
              outer: ImageFilter.blur(
                sigmaX: animation * 5,
                sigmaY: animation * 5,
              ),
              inner: ColorFilter.mode(context.theme.colors.barrier, .srcOver),
            ),
      ),
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          direction: Axis.horizontal,
          style: style,
          animation: animation,
          body: Text(
            'extension-repo.remove_confirm_with_name'.fill({
              'name': selected.toString(),
            }),
          ),
          actions: [
            FButton(
              onPress: () async {
                for (var url in selected) {
                  final res = await MiruCoreEndpoint.deleteRepo(url);
                  logger.info('Deleted repo $url: $res');
                }
                if (!context.mounted) {
                  return;
                }
                ref.invalidate(extensionRepoProvider);
                ref.read(extensionRepoProvider);
                Navigator.of(context).pop();
              },
              child: Text('continue_text'.i18n),
            ),
            FButton(
              variant: .outline,
              onPress: () => Navigator.of(context).pop(),
              child: Text('cancel'.i18n),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(<String>{});
    final selectAll = useState(false);
    final reposAsync = ref.watch(extensionRepoProvider);
    return (MiruListView(
      children: [
        if (isMobile)
          reposAsync.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (err, st) => Text('extension-repo.load_error'.fill({'error': err.toString()})),
            data: (repos) {
              // final selectController = useFSelectGroupController<String>();
              return FTileGroup(
                // selectController: selectController,
                label: Text('extension-repo.management'.i18n),
                children: [
                  ...repos.map((repo) {
                    final name = repo.name;
                    final url = repo.link;

                    return FTile(
                      prefix: selected.value.contains(url)
                          ? Icon(FIcons.check)
                          : SizedBox(width: 18),
                      title: Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(url),
                      onPress: () {
                        final val = selected.value;
                        if (val.contains(url)) {
                          val.remove(url);
                          selected.value = Set.from(val);
                          return;
                        }
                        val.add(url);
                        selected.value = Set.from(val);
                      },
                    );
                  }),
                  if (selected.value.isEmpty)
                    FTile(
                      title: Text('add'.i18n),
                      prefix: Icon(FIcons.plus),
                      onPress: () {
                        showFDialog(
                          context: context,
                          builder: (context, style, animation) {
                            return MobileRepoDialog(
                              style: style.call,
                              animation: animation,
                            );
                          },
                        );
                      },
                    )
                  else
                    FTile(
                      title: Text('extension.uninstall'.i18n),
                      prefix: Icon(FIcons.trash),
                      onPress: () {
                        showRepoRemoveDialog(context, ref, selected.value);
                      },
                    ),
                  // FTile.raw(, child: Icon(FIcons.plus), onPress: () {}),
                  // FSelectTile(title: Text(''), value: 'Text('')'),
                ],
              );
            },
          )
        else
          OutterCard(
            title: 'extension-repo.management',
            trailing: isMobile
                ? null
                : Row(
                    children: [
                      if (selected.value.isNotEmpty) ...[
                        FButton(
                          onPress: () => showRepoRemoveDialog(
                            context,
                            ref,
                            selected.value,
                          ),
                          child: Text('extension.uninstall'.i18n),
                        ),
                        SizedBox(width: 10),
                      ],
                      FButton(
                        onPress: () => showFDialog(
                          routeStyle: .delta(
                            barrierFilter: () =>
                                (animation) => ImageFilter.compose(
                                  outer: ImageFilter.blur(
                                    sigmaX: animation * 5,
                                    sigmaY: animation * 5,
                                  ),
                                  inner: ColorFilter.mode(
                                    context.theme.colors.barrier,
                                    .srcOver,
                                  ),
                                ),
                          ),
                          context: context,
                          builder: (context, style, animation) {
                            return RepoDialog(
                              animation: animation,
                              style: style,
                            );
                          },
                        ),
                        child: Text('add'.i18n),
                      ),
                    ],
                  ),
            child: reposAsync.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (err, st) => Text('extension-repo.load_error'.fill({'error': err.toString()})),
              data: (repos) {
                if (isMobile) {
                  final selectController = useFMultiValueNotifier<String>();
                  return FSelectTileGroup(
                    control: .managed(controller: selectController),
                    children: repos.map((repo) {
                      final name = repo.name;
                      final url = repo.link;
                      return FSelectTile(
                        title: Text(name),
                        value: url,
                        // suffix: Text(url),
                      );
                    }).toList(),
                  );
                }
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          child: FCheckbox(
                            value: selectAll.value,
                            label: const Text(""),
                            onChange: (value) {
                              selectAll.value = value;
                              if (value) {
                                for (var repo in repos) {
                                  final url = repo.link;
                                  selected.value = Set.from(selected.value)
                                    ..add(url);
                                }
                              } else {
                                selected.value = {};
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "name".i18n,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "extension-repo.url".i18n,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    FDivider(),
                    if (repos.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('extension-repo.no_repos_found'.i18n),
                      )
                    else
                      ...buildSeparators(
                        buildRepoSetting(selectAll, selected, repos),
                      ),
                  ],
                );
              },
            ),
          ),
      ],
    ));
  }
}
