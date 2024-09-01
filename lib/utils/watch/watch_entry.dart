import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';

class WatchEntry {
  static handlePageRoute(ExtensionApiV1 extension, BuildContext context) {
    switch (extension.extension.type) {
      case ExtensionType.bangumi:
        context.go('/bangumi');
        break;
      case ExtensionType.manga:
        context.go('/manga');
        break;
      case ExtensionType.fikushon:
        context.go('/fikushon');
        break;
    }
  }
}

class WatchParams {
  const WatchParams(
      {required this.service,
      required this.type,
      required this.url,
      required this.selectedGroupIndex,
      required this.selectedEpisodeIndex,
      required this.name,
      required this.detailImageUrl,
      required this.epGroup});
  final ExtensionApiV1 service;
  final String url;
  final List<ExtensionEpisodeGroup>? epGroup;
  final int selectedGroupIndex;
  final String detailImageUrl;
  final int selectedEpisodeIndex;
  final ExtensionType type;
  final String name;
}
