import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/setting/view_models/settings_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(settingsViewModelProvider);

    return MiruScaffold.mobile(
      sliverHeaders: [
        FlexibleHeaderDelegate(
          scrollPosition: useValueNotifier(0.0),
          maxExtent: 180,
          minExtent: 120,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SnapSheetHeader(title: 'settings.title'.i18n, suffix: []);
          },
        ),
      ],
      slivers: [
        if (viewModelAsync.isLoading)
          const SliverFillRemaining(child: LoadingState())
        else if (viewModelAsync.hasError)
          SliverFillRemaining(
            child: ErrorState(message: 'settings.load_failed'.i18n),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final settings = viewModelAsync.value!;
                final items = <_SettingItem>[
                  _SettingItem(
                    'settings.theme'.i18n,
                    settings.theme,
                    (value) => ref
                        .read(settingsViewModelProvider.notifier)
                        .updateTheme(value),
                  ),
                  _SettingItem(
                    'settings.language'.i18n,
                    settings.language,
                    (value) => ref
                        .read(settingsViewModelProvider.notifier)
                        .updateLanguage(value),
                  ),
                  _SettingItem(
                    'settings.mobile_title_on_top'.i18n,
                    settings.isMobileTitleOnTop ? 'ON' : 'OFF',
                    (value) => ref
                        .read(settingsViewModelProvider.notifier)
                        .updateMobileTitleOnTop(value == 'ON'),
                  ),
                ];
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.label),
                    subtitle: Text(item.value),
                    trailing: FSwitch(
                      value: item.value == 'ON',
                      onChange: (value) {
                        item.onChanged(value ? 'ON' : 'OFF');
                      },
                    ),
                  ),
                );
              }, childCount: 3),
            ),
          ),
      ],
    );
  }
}

class _SettingItem {
  const _SettingItem(this.label, this.value, this.onChanged);

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
}
