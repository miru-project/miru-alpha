import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network/network.dart';
import 'package:miru_app_new/provider/settingpage_provider.dart';
import 'package:miru_app_new/widgets/core/setting_card.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/widgets/core/seperator.dart';

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
                label: Text('Name'),
                initialText: "",
                autovalidateMode: AutovalidateMode.always,
                hint: 'Official Repo',
                onChange: (value) => name.value = value,
                validator: (val) => (val?.isEmpty ?? false) ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              FTextFormField(
                initialText: "",
                onChange: (value) => url.value = value,
                label: Text('Repo URL'),
                hint: 'https://miru-repo.0n0.dev/index.json',
                autovalidateMode: AutovalidateMode.always,
                validator: (value) => (value?.contains('.json') ?? false) ? null : 'Repo url must contain .json extension.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        FButton(
          onPress:
              (name.value.isEmpty && !url.value.contains('.json'))
                  ? null
                  : () async {
                    await CoreNetwork.requestFormData('ext/repo', {'repoUrl': url.value, 'name': name.value});
                    ref.invalidate(extensionRepoProvider);
                    ref.read(extensionRepoProvider.future);
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                  },
          child: const Text('Save'),
        ),
        FButton(style: FButtonStyle.outline(), onPress: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ],
    );
  }
}

class SettingExtension extends HookConsumerWidget {
  const SettingExtension({super.key});

  List<Widget> buildRepoSetting(ValueNotifier<bool> selectAll, ValueNotifier<Set<String>> selected, List<dynamic> repos) {
    return repos.map((repo) {
      final name = (repo is Map && (repo['name'] ?? repo['title']) != null) ? (repo['name'] ?? repo['title']).toString() : repo.toString();
      final url = (repo is Map && repo['url'] != null) ? repo['url'].toString() : '';
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
                    if (v) {
                      selected.value = Set.from(selected.value)..add(url);
                    } else {
                      selected.value = Set.from(selected.value)..remove(url);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: Text(name, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: Text(url, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(<String>{});
    final selectAll = useState(false);
    final reposAsync = ref.watch(extensionRepoProvider);
    return MiruListView(
      children: [
        SettingCard(
          title: 'repo-setting',
          trailing: Row(
            children: [
              if (selected.value.isNotEmpty) ...[
                FButton(
                  onPress:
                      () => showFDialog(
                        style:
                            context.theme.dialogStyle
                                .copyWith(
                                  barrierFilter:
                                      (animation) => ImageFilter.compose(
                                        outer: ImageFilter.blur(sigmaX: animation * 5, sigmaY: animation * 5),
                                        inner: ColorFilter.mode(context.theme.colors.barrier, BlendMode.srcOver),
                                      ),
                                )
                                .call,
                        context: context,
                        builder: (context, style, animation) {
                          return FDialog(
                            style: style.call,
                            animation: animation,
                            title: const Text('Are you absolutely sure?'),
                            body: const Text('This action cannot be undone. This will permanently delete the selected extension repositories.'),
                            actions: [
                              FButton(
                                onPress: () async {
                                  for (var url in selected.value) {
                                    await CoreNetwork.requestFormData('ext/repo', {'repoUrl': url}, method: 'DELETE');
                                  }
                                  if (!context.mounted) {
                                    return;
                                  }
                                  ref.invalidate(extensionRepoProvider);
                                  ref.read(extensionRepoProvider.future);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Continue'),
                              ),
                              FButton(style: FButtonStyle.outline(), onPress: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                            ],
                          );
                        },
                      ),
                  child: const Text('remove-repo'),
                ),
                SizedBox(width: 10),
              ],
              FButton(
                onPress:
                    () => showFDialog(
                      style:
                          context.theme.dialogStyle
                              .copyWith(
                                barrierFilter:
                                    (animation) => ImageFilter.compose(
                                      outer: ImageFilter.blur(sigmaX: animation * 5, sigmaY: animation * 5),
                                      inner: ColorFilter.mode(context.theme.colors.barrier, BlendMode.srcOver),
                                    ),
                              )
                              .call,
                      context: context,
                      builder: (context, style, animation) {
                        return RepoDialog(animation: animation, style: style.call);
                      },
                    ),
                child: const Text('add-repo'),
              ),
            ],
          ),
          child: reposAsync.when(
            loading: () => const Center(child: FProgress.circularIcon()),
            error: (err, st) => Text('Error loading repos: $err'),
            data:
                (repos) => Column(
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
                                  final url = (repo is Map && repo['url'] != null) ? repo['url'].toString() : '';
                                  selected.value = Set.from(selected.value)..add(url);
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
                          child: Text("name", overflow: TextOverflow.ellipsis, style: TextStyle(color: context.theme.colors.mutedForeground)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Text("url", overflow: TextOverflow.ellipsis, style: TextStyle(color: context.theme.colors.mutedForeground)),
                        ),
                      ],
                    ),
                    FDivider(),
                    if (repos.isEmpty)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('No extension repositories found.'))
                    else
                      ...buildSeparators(buildRepoSetting(selectAll, selected, repos)),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}
