import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:miru_alpha/domain/models/extension.dart';

part 'extension_view.freezed.dart';
part 'extension_view.g.dart';

@freezed
abstract class DomainExtensionViewState with _$DomainExtensionViewState {
  const factory DomainExtensionViewState({
    @Default([]) List<DomainExtensionRepo> repos,
    @Default([]) List<DomainExtensionRepo> extensions,
    @Default([]) List<String> installedPackages,
    @Default([]) List<DomainExtensionMeta> metadata,
    @Default('') String selectedRepoName,
    @Default('') String query,
    @Default(ExtensionType.all) ExtensionType typeFilter,
    @Default(ExtensionInstallStatus.all) ExtensionInstallStatus installFilter,
    @Default(false) bool isLoading,
  }) = _DomainExtensionViewState;

  factory DomainExtensionViewState.fromJson(Map<String, dynamic> json) =>
      _$DomainExtensionViewStateFromJson(json);
}
