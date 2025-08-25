import 'dart:convert';

import 'package:miru_app_new/miru_core/network/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';

class ExtensionApi {
  ExtensionMeta meta;
  ExtensionApi(this.meta);

  Future<BaseWatch?> watch(String url) async {
    // This method should be implemented in subclasses
    throw UnimplementedError('watch method not implemented');
  }

  Future<ExtensionDetail> detail(String url) async {
    // This method should be implemented in subclasses
    throw UnimplementedError('detail method not implemented');
  }

  Future<List<ExtensionListItem>> search(
    String kw,
    int page, {
    Map<String, List<String>>? filter,
  }) async {
    // This method should be implemented in subclasses
    throw UnimplementedError('search method not implemented');
  }

  Future<Map<String, ExtensionFilter>> createFilter({
    Map<String, List<String>>? filter,
  }) async {
    // This method should be implemented in subclasses
    throw UnimplementedError('createFilter method not implemented');
  }

  Future<List<ExtensionListItem>> latest(int page) async {
    final jsResult = await ExtensionEndpoint.latest(meta.packageName, page);

    List<ExtensionListItem> result =
        jsonDecode(jsResult).map<ExtensionListItem>((e) {
          return ExtensionListItem.fromJson(e);
        }).toList();
    // for (var element in result) {
    //   element.headers ??= await _defaultHeaders;
    // }
    return result;
  }
}
