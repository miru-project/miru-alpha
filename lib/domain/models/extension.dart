import 'package:freezed_annotation/freezed_annotation.dart';

part 'extension.freezed.dart';
part 'extension.g.dart';

@freezed
abstract class DomainExtension with _$DomainExtension {
  const factory DomainExtension({
    required String package,
    required String author,
    required String version,
    required String lang,
    required String license,
    required ExtensionType type,
    required String webSite,
    required String name,
    @Default(false) bool nsfw,
    String? icon,
    String? url,
    String? description,
  }) = _DomainExtension;

  factory DomainExtension.fromJson(Map<String, dynamic> json) =>
      _$DomainExtensionFromJson(json);
}

enum ExtensionType { manga, bangumi, fikushon, all }

/// Filter value for the extension install-status selector.
enum ExtensionInstallStatus { all, installed, notInstalled }

extension ExtensionInstallStatusX on ExtensionInstallStatus {
  /// Parse a raw string into the matching install-status value.
  static ExtensionInstallStatus fromRaw(String? value) => switch (value) {
    'extension.installed' => ExtensionInstallStatus.installed,
    'extension.not_installed' => ExtensionInstallStatus.notInstalled,
    _ => ExtensionInstallStatus.all,
  };
}

@freezed
abstract class DomainExtensionMeta with _$DomainExtensionMeta {
  const factory DomainExtensionMeta({
    @Default('') String name,
    @Default('') String version,
    @Default('') String author,
    @Default('') String license,
    @Default('') String lang,
    String? icon,
    @Default('') String packageName,
    @Default('') String webSite,
    String? description,
    @Default([]) List<dynamic> tags,
    @Default('') String api,
    required ExtensionType type,
    String? error,
    @Default(false) bool nsfw,
  }) = _DomainExtensionMeta;

  factory DomainExtensionMeta.fromJson(Map<String, dynamic> json) =>
      _$DomainExtensionMetaFromJson(json);
}

@freezed
abstract class DomainExtensionRepo with _$DomainExtensionRepo {
  const factory DomainExtensionRepo({
    required String name,
    required String url,
    @Default([]) List<DomainExtensionMeta> extensions,
  }) = _DomainExtensionRepo;

  factory DomainExtensionRepo.fromJson(Map<String, dynamic> json) =>
      _$DomainExtensionRepoFromJson(json);
}
