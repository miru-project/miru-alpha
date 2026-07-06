// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainExtensionViewState _$DomainExtensionViewStateFromJson(
  Map<String, dynamic> json,
) => _DomainExtensionViewState(
  repos:
      (json['repos'] as List<dynamic>?)
          ?.map((e) => DomainExtensionRepo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  extensions:
      (json['extensions'] as List<dynamic>?)
          ?.map((e) => DomainExtensionRepo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  installedPackages:
      (json['installedPackages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  metadata:
      (json['metadata'] as List<dynamic>?)
          ?.map((e) => DomainExtensionMeta.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  selectedRepoName: json['selectedRepoName'] as String? ?? '',
  query: json['query'] as String? ?? '',
  typeFilter: json['typeFilter'] as String? ?? 'ALL',
  installFilter: json['installFilter'] as String? ?? 'ALL',
  isLoading: json['isLoading'] as bool? ?? false,
);

Map<String, dynamic> _$DomainExtensionViewStateToJson(
  _DomainExtensionViewState instance,
) => <String, dynamic>{
  'repos': instance.repos,
  'extensions': instance.extensions,
  'installedPackages': instance.installedPackages,
  'metadata': instance.metadata,
  'selectedRepoName': instance.selectedRepoName,
  'query': instance.query,
  'typeFilter': instance.typeFilter,
  'installFilter': instance.installFilter,
  'isLoading': instance.isLoading,
};
