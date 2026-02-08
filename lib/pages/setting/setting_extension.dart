import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/provider/setting_page_provider.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/widgets/core/outter_card.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/widgets/core/seperator.dart';

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
        style: style,
        animation: animation,
        direction: Axis.horizontal,
        title: const Text('Add Repo?', style: TextStyle(fontSize: 25)),
        body: Padding(
          padding: EdgeInsetsGeometry.only(top: 20, bottom: 10),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FTextFormField(
                  label: Text('Name'),
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(text: name.value),
                    onChange: (value) => name.value = value.text,
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  hint: 'Official Repo',
                  validator: (val) =>
                      (val?.isEmpty ?? false) ? 'Name cannot be empty' : null,
                ),
                SizedBox(height: 10),
                FTextFormField(
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(text: url.value),
                    onChange: (value) => url.value = value.text,
                  ),
                  label: Text('Repo URL'),
                  hint: 'https://miru-repo.0n0.dev/index.json',
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) => (value?.contains('.json') ?? false)
                      ? null
                      : 'Repo url must contain .json extension.',
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
            child: const Text('Save'),
          ),
          FButton(
            style: FButtonStyle.outline(),
            onPress: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class RepoDialog extends HookConsumerWidget {
  const RepoDialog({super.key, required this.style, required this.animation});
  final FDialogStyle Function(FDialogStyle)? style;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useState('');
    final url = useState('');
    return FDialog(
      style: style?.call,
      animation: animation,
      direction: Axis.horizontal,
      title: const Text('Add Repo?'),
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
                label: Text('Name'),
                autovalidateMode: AutovalidateMode.always,
                hint: 'Official Repo',
                validator: (val) =>
                    (val?.isEmpty ?? false) ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              FTextFormField(
                control: FTextFieldControl.managed(
                  initial: TextEditingValue(text: url.value),
                  onChange: (value) => url.value = value.text,
                ),
                label: Text('Repo URL'),
                hint: 'https://miru-repo.0n0.dev/index.json',
                autovalidateMode: AutovalidateMode.always,
                validator: (value) => (value?.contains('.json') ?? false)
                    ? null
                    : 'Repo url must contain .json extension.',
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
          child: const Text('Save'),
        ),
        FButton(
          style: FButtonStyle.outline(),
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
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
    List<Map<String, dynamic>> repos,
  ) {
    return repos.map((repo) {
      final name = repo['name']?.toString() ?? 'Untitled';
      final url = repo['link']?.toString() ?? '';
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
      routeStyle: context.theme.dialogRouteStyle
          .copyWith(
            barrierFilter: (animation) => ImageFilter.compose(
              outer: ImageFilter.blur(
                sigmaX: animation * 5,
                sigmaY: animation * 5,
              ),
              inner: ColorFilter.mode(
                context.theme.colors.barrier,
                BlendMode.srcOver,
              ),
            ),
          )
          .call,
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          direction: Axis.horizontal,
          style: style.call,
          animation: animation,
          title: const Text('Are you absolutely sure?'),
          body: Text('Remove ${selected.toString()} from repo?'),
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
              child: const Text('Continue'),
            ),
            FButton(
              style: FButtonStyle.outline(),
              onPress: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
            error: (err, st) => Text('Error loading repos: $err'),
            data: (repos) {
              final repoList = repos.whereType<Map<String, dynamic>>().toList();
              // final selectController = useFSelectGroupController<String>();
              return FTileGroup(
                // selectController: selectController,
                label: Text('Repo Management'),
                children: [
                  ...repoList.map((repo) {
                    final name = repo['name']?.toString() ?? 'Untitled';
                    final url = repo['link']?.toString() ?? '';

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
                      title: Text('Add'),
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
                      title: Text('Remove'),
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
            title: 'Repo Management',
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
                          child: const Text('Remove'),
                        ),
                        SizedBox(width: 10),
                      ],
                      FButton(
                        onPress: () => showFDialog(
                          routeStyle: context.theme.dialogRouteStyle
                              .copyWith(
                                barrierFilter: (animation) =>
                                    ImageFilter.compose(
                                      outer: ImageFilter.blur(
                                        sigmaX: animation * 5,
                                        sigmaY: animation * 5,
                                      ),
                                      inner: ColorFilter.mode(
                                        context.theme.colors.barrier,
                                        BlendMode.srcOver,
                                      ),
                                    ),
                              )
                              .call,
                          context: context,
                          builder: (context, style, animation) {
                            return RepoDialog(
                              animation: animation,
                              style: style.call,
                            );
                          },
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
            child: reposAsync.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (err, st) => Text('Error loading repos: $err'),
              data: (repos) {
                final repoList = repos
                    .whereType<Map<String, dynamic>>()
                    .toList();
                if (isMobile) {
                  final selectController = useFMultiValueNotifier<String>();
                  return FSelectTileGroup(
                    control: .managed(controller: selectController),
                    children: repoList.map((repo) {
                      final name = repo['name']?.toString() ?? 'Untitled';
                      final url = repo['link']?.toString() ?? '';
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
                                  final url =
                                      (repo is Map && repo['url'] != null)
                                      ? repo['url'].toString()
                                      : '';
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
                            "name",
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
                            "url",
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No extension repositories found.'),
                      )
                    else
                      ...buildSeparators(
                        buildRepoSetting(selectAll, selected, repoList),
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
