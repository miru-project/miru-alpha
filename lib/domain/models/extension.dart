import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/common.pb.dart'
    as common_model;

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

extension ExtensionTypeX on ExtensionType {
  /// Map a backend/JSON media-type string onto the canonical value. Legacy
  /// aliases are not accepted; anything unknown falls back to [all] so a bad
  /// value never fails to parse.
  static ExtensionType fromRaw(String? value) => switch (value?.toLowerCase()) {
    'manga' => ExtensionType.manga,
    'bangumi' => ExtensionType.bangumi,
    'fikushon' => ExtensionType.fikushon,
    _ => ExtensionType.all,
  };
}

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

  /// Installed-extension snapshot pushed by miru-core, both on the initial
  /// hello and on every extension-folder change.
  factory DomainExtensionMeta.fromProto(common_model.ExtensionMeta meta) {
    return DomainExtensionMeta(
      name: meta.name,
      version: meta.version,
      author: meta.author,
      license: meta.license,
      lang: meta.lang,
      icon: meta.icon,
      packageName: meta.package,
      webSite: meta.webSite,
      description: meta.description,
      tags: meta.tags.toList(),
      api: meta.api,
      type: ExtensionTypeX.fromRaw(meta.type),
      error: meta.error,
      nsfw: meta.nsfw,
    );
  }
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
