import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'search_page_provider.g.dart';

class SearchPageState {
  final List<ExtensionMeta> metaData;
  final Set<String> pinnedExtensions;
  final String query;
  final Set<String> existedPinnedExtensions;
  final String? selectedLang;
  final ExtensionType? selectedType;
  final bool open;
  final List<String> history;
  final bool pinnedScope;
  SearchPageState({
    required this.metaData,
    required this.pinnedExtensions,
    required this.query,
    required this.existedPinnedExtensions,
    this.selectedLang,
    this.selectedType,
    this.open = false,
    this.history = const [],
    this.pinnedScope = false,
  });

  List<ExtensionMeta> get filteredMetaData {
    var result = metaData;
    if (selectedLang != null) {
      result = result.where((e) {
        final base = e.lang.split(RegExp(r'[-_]')).first;
        return base == selectedLang;
      }).toList();
    }
    if (selectedType != null && selectedType != ExtensionType.all) {
      result = result.where((e) => e.type == selectedType).toList();
    }
    return result;
  }

  // Package names that global search should iterate, honoring both the pinned
  // scope toggle and the selected type filter from the search bar.
  Set<String> get searchScopePackages {
    final base = pinnedScope
        ? existedPinnedExtensions
        : metaData.map((e) => e.packageName).toSet();
    if (selectedType != null && selectedType != ExtensionType.all) {
      final allowed = filteredMetaData.map((e) => e.packageName).toSet();
      return base.intersection(allowed);
    }
    return base;
  }

  // Recently visited extensions (newest first), backed by the fixed-size
  // RecentExtensions setting (updated when an extension's latest page is
  // opened), rather than parsed from search history.
  List<String> get recentExtensions =>
      MiruSettings.getRecentExtensions();

  SearchPageState copyWith({
    List<ExtensionMeta>? metaData,
    Set<String>? pinnedExtensions,
    String? query,
    Set<String>? existedPinnedExtensions,
    String? selectedLang,
    ExtensionType? selectedType,
    bool? open,
    List<String>? history,
    bool? pinnedScope,
    bool clearLang = false,
    bool clearType = false,
  }) {
    return SearchPageState(
      existedPinnedExtensions:
          existedPinnedExtensions ?? this.existedPinnedExtensions,
      metaData: metaData ?? this.metaData,
      pinnedExtensions: pinnedExtensions ?? this.pinnedExtensions,
      query: query ?? this.query,
      selectedLang: clearLang ? null : (selectedLang ?? this.selectedLang),
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      open: open ?? this.open,
      history: history ?? this.history,
      pinnedScope: pinnedScope ?? this.pinnedScope,
    );
  }
}

@Riverpod(keepAlive: true)
class SearchPageNotifier extends _$SearchPageNotifier {
  @override
  SearchPageState build() {
    // listen to extension page provider
    ref.listen(extensionPageProvider.select((e) => e.metaData), (prev, next) {
      final existedPinnedExtension = next
          .where(
            (ext) => MiruSettings.getSettingSync<Set<String>>(
              SettingKey.pinnedExtension,
            ).contains(ext.packageName),
          )
          .map((e) => e.packageName)
          .toSet();
      MiruSettings.setSettingSync(
        SettingKey.pinnedExtension,
        existedPinnedExtension.toString(),
      );
      state = state.copyWith(
        metaData: next,
        existedPinnedExtensions: existedPinnedExtension,
      );
    });

    return SearchPageState(
      metaData: ref.read(extensionPageProvider).metaData,
      pinnedExtensions: {},
      query: '',
      existedPinnedExtensions: ref
          .read(extensionPageProvider.select((e) => e.metaData))
          .where(
            (ext) => MiruSettings.getSettingSync<Set<String>>(
              SettingKey.pinnedExtension,
            ).contains(ext.packageName),
          )
          .map((e) => e.packageName)
          .toSet(),
      history: _loadHistory(),
    );
  }

  List<String> _loadHistory() {
    final raw = MiruSettings.getSettingSync<String>(SettingKey.searchHistory);
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  void setMetaData(List<ExtensionMeta> metaData) {
    state = state.copyWith(metaData: metaData);
  }

  void setPinnedExtensions(Set<String> pinnedExtensions) {
    state = state.copyWith(pinnedExtensions: pinnedExtensions);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setOpen(bool open) {
    state = state.copyWith(open: open);
  }

  void setExistedPinnedExtensions(Set<String> existedPinnedExtensions) {
    state = state.copyWith(existedPinnedExtensions: existedPinnedExtensions);
  }

  void setPinnedScope(bool pinnedScope) {
    state = state.copyWith(pinnedScope: pinnedScope);
  }

  void setSelectedLang(String? lang) {
    state = state.copyWith(selectedLang: lang, clearLang: lang == null);
  }

  void setSelectedType(ExtensionType? type) {
    state = state.copyWith(selectedType: type, clearType: type == null);
  }

  void addHistory(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final next = [
      trimmed,
      ...state.history.where((e) => e != trimmed),
    ].take(10).toList();
    state = state.copyWith(history: next);
    MiruSettings.setSettingSync(SettingKey.searchHistory, jsonEncode(next));
  }

  void removeHistory(String query) {
    final next = state.history.where((e) => e != query).toList();
    state = state.copyWith(history: next);
    MiruSettings.setSettingSync(SettingKey.searchHistory, jsonEncode(next));
  }

  void clearHistory() {
    state = state.copyWith(history: const []);
    MiruSettings.setSettingSync(
      SettingKey.searchHistory,
      jsonEncode(<String>[]),
    );
  }
}
