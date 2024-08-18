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
      {required this.url,
      required this.service,
      required this.type,
      required this.epGroup});
  final String url;
  final ExtensionApiV1 service;
  final ExtensionType type;
  final List<ExtensionEpisodeGroup>? epGroup;
}
