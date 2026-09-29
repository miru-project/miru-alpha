import 'package:freezed_annotation/freezed_annotation.dart';

part 'search.freezed.dart';
part 'search.g.dart';

@freezed
abstract class DomainSearchFilter with _$DomainSearchFilter {
  const factory DomainSearchFilter({
    String? lang,
    String? type,
    @Default(false) bool installedOnly,
    @Default(false) bool notInstalledOnly,
  }) = _DomainSearchFilter;

  factory DomainSearchFilter.fromJson(Map<String, dynamic> json) =>
      _$DomainSearchFilterFromJson(json);
}

@freezed
abstract class DomainSearchState with _$DomainSearchState {
  const factory DomainSearchState({
    required List<dynamic> extensions,
    required String query,
    String? selectedLang,
    String? selectedType,
    @Default(false) bool isLoading,
    String? error,
  }) = _DomainSearchState;

  factory DomainSearchState.fromJson(Map<String, dynamic> json) =>
      _$DomainSearchStateFromJson(json);
}
