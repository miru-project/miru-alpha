import 'package:miru_alpha/data/repositories/settings_repository.dart';
import 'package:miru_alpha/data/services/settings_service.dart';
import 'package:miru_alpha/domain/models/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_view_model.g.dart';

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  @override
  Future<DomainAppSettings> build() async {
    final repository = SettingsRepository(SettingsService());
    return await repository.getAppSettings();
  }

  Future<void> updateSettings(DomainAppSettings settings) async {
    final repository = SettingsRepository(SettingsService());
    await repository.updateAppSettings(settings);
    state = AsyncValue.data(settings);
  }

  Future<void> updateTheme(String theme) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(theme: theme);
    await updateSettings(updated);
  }

  Future<void> updateAccentColor(int color) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(accentColor: color);
    await updateSettings(updated);
  }

  Future<void> updateLanguage(String language) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(language: language);
    await updateSettings(updated);
  }

  Future<void> updateMobileTitleOnTop(bool isOnTop) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(isMobileTitleOnTop: isOnTop);
    await updateSettings(updated);
  }
}
