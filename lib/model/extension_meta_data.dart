import 'package:json_annotation/json_annotation.dart';
import 'package:miru_app_new/model/model.dart';

part 'extension_meta_data.g.dart';

ExtensionType _extensionTypeFromJson(String value) {
  return switch (value.toLowerCase()) {
    'manga' => ExtensionType.manga,
    'fikushon' => ExtensionType.fikushon,
    'bangumi' => ExtensionType.bangumi,
    'unknown' => ExtensionType.unknown,
    _ => ExtensionType.unknown,
  };
}

@JsonSerializable()
class ExtensionMeta {
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String version;
  @JsonKey(defaultValue: '')
  final String author;
  @JsonKey(defaultValue: '')
  final String license;
  @JsonKey(defaultValue: '')
  final String lang;
  final String? icon;
  @JsonKey(name: 'package', defaultValue: '')
  final String packageName;
  @JsonKey(defaultValue: '')
  final String webSite;
  final String? description;
  @JsonKey(defaultValue: []) // Explicit default value for list
  final List<dynamic>? tags;
  @JsonKey(defaultValue: '')
  final String api;
  @JsonKey(fromJson: _extensionTypeFromJson)
  final ExtensionType type;

  ExtensionMeta({
    required this.name,
    required this.version,
    required this.author,
    required this.license,
    required this.lang,
    this.icon,
    required this.packageName,
    required this.webSite,
    this.description,
    required this.tags,
    required this.api,
    required this.type,
  });

  factory ExtensionMeta.fromJson(Map<String, dynamic> json) => _$ExtensionMetaFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionMetaToJson(this);
}
