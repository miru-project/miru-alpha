import 'package:miru_app_new/model/model.dart';

class ExtensionMeta {
  final String name;
  final String version;
  final String author;
  final String license;
  final String lang;
  final String? icon;
  final String packageName;
  final String webSite;
  final String? description;
  final List<dynamic>? tags;
  final String api;
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

  factory ExtensionMeta.fromJson(Map<String, dynamic> json) {
    return ExtensionMeta(
      type: switch (json['type']!.toLowerCase()) {
        'manga' => ExtensionType.manga,
        'fikushon' => ExtensionType.fikushon,
        'bangumi' => ExtensionType.bangumi,
        'unknown' => ExtensionType.unknown,
        _ => ExtensionType.unknown,
      },
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      author: json['author'] ?? '',
      license: json['license'] ?? '',
      lang: json['lang'] ?? '',
      icon: json['icon'],
      packageName: json['package'] ?? '',
      webSite: json['webSite'] ?? '',
      description: json['description'],
      tags: json['tags'] ?? [],
      api: json['api'] ?? '',
    );
  }
}
