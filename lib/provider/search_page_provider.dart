import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/store/miru_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'search_page_provider.g.dart';

class SearchPageState {
  final List<ExtensionMeta> metaData;
  final Set<String> pinnedExtensions;
  final String query;
  final Set<String> existedPinnedExtensions;
  SearchPageState({
    required this.metaData,
    required this.pinnedExtensions,
    required this.query,
    required this.existedPinnedExtensions,
  });

  SearchPageState copyWith({
    List<ExtensionMeta>? metaData,
    Set<String>? pinnedExtensions,
    String? query,
    Set<String>? existedPinnedExtensions,
  }) {
    return SearchPageState(
      existedPinnedExtensions:
          existedPinnedExtensions ?? this.existedPinnedExtensions,
      metaData: metaData ?? this.metaData,
      pinnedExtensions: pinnedExtensions ?? this.pinnedExtensions,
      query: query ?? this.query,
    );
  }
}

@riverpod
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
      state = state.copyWith(existedPinnedExtensions: existedPinnedExtension);
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
}
