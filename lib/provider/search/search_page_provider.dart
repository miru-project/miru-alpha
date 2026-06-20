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
  SearchPageState({
    required this.metaData,
    required this.pinnedExtensions,
    required this.query,
    required this.existedPinnedExtensions,
    this.selectedLang,
    this.selectedType,
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

  SearchPageState copyWith({
    List<ExtensionMeta>? metaData,
    Set<String>? pinnedExtensions,
    String? query,
    Set<String>? existedPinnedExtensions,
    String? selectedLang,
    ExtensionType? selectedType,
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
    );
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

  void setExistedPinnedExtensions(Set<String> existedPinnedExtensions) {
    state = state.copyWith(existedPinnedExtensions: existedPinnedExtensions);
  }

  void setSelectedLang(String? lang) {
    state = state.copyWith(selectedLang: lang, clearLang: lang == null);
  }

  void setSelectedType(ExtensionType? type) {
    state = state.copyWith(selectedType: type, clearType: type == null);
  }
}
