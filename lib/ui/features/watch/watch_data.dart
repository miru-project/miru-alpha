import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;

/// The Go engine returns the resolved watch result as a raw `Map`/`String` for
/// V2 ("api == 2" / raw) extensions (see `MiruCoreEndpoint.mirror`). The player
/// widgets however expect a typed protobuf object. Normalize the raw data here
/// so a `Map`/`String` does not crash the widget tree with a _TypeError
/// ("type 'X' is not a subtype of type 'Y'") during build.
ExtensionBangumiWatch toBangumiWatch(dynamic data) {
  if (data is ExtensionBangumiWatch) return data;
  if (data is String) return ExtensionBangumiWatch()..url = data;
  if (data is List) return bangumiFromList(data);
  if (data is Map) {
    return ExtensionBangumiWatch()..mergeFromProto3Json(
      Map<String, dynamic>.from(data),
      ignoreUnknownFields: true,
    );
  }
  throw Exception('Unsupported bangumi watch data type: ${data.runtimeType}');
}

/// The Go engine may resolve a mirror into a list of candidate sources
/// (e.g. multiple qualities / mirrors). Pick the first usable one.
ExtensionBangumiWatch bangumiFromList(List list) {
  for (final item in list) {
    if (item is String && item.isNotEmpty) {
      return ExtensionBangumiWatch()..url = item;
    }
    if (item is Map && item['url'] != null) {
      return ExtensionBangumiWatch()..mergeFromProto3Json(
        Map<String, dynamic>.from(item),
        ignoreUnknownFields: true,
      );
    }
  }
  if (list.isNotEmpty) return ExtensionBangumiWatch(url: list.first.toString());
  throw Exception('Empty watch data list');
}

ExtensionMangaWatch toMangaWatch(dynamic data) {
  if (data is ExtensionMangaWatch) return data;
  if (data is List) {
    final urls = <String>[];
    for (final item in data) {
      if (item is String && item.isNotEmpty) {
        urls.add(item);
      } else if (item is Map && item['url'] != null) {
        urls.add(item['url'].toString());
      }
    }
    return ExtensionMangaWatch()..urls.addAll(urls);
  }
  if (data is Map) {
    return ExtensionMangaWatch()..mergeFromProto3Json(
      Map<String, dynamic>.from(data),
      ignoreUnknownFields: true,
    );
  }
  throw Exception('Unsupported manga watch data type: ${data.runtimeType}');
}

ExtensionFikushonWatch toNovelWatch(dynamic data) {
  if (data is ExtensionFikushonWatch) return data;
  if (data is List) {
    final content = <String>[];
    for (final item in data) {
      if (item is String && item.isNotEmpty) {
        content.add(item);
      } else if (item is Map && item['content'] != null) {
        content.add(item['content'].toString());
      }
    }
    return ExtensionFikushonWatch()..content.addAll(content);
  }
  if (data is Map) {
    return ExtensionFikushonWatch()..mergeFromProto3Json(
      Map<String, dynamic>.from(data),
      ignoreUnknownFields: true,
    );
  }
  throw Exception('Unsupported novel watch data type: ${data.runtimeType}');
}

/// An "all" extension (golang) returns an ExtensionAllWatch that bundles the
/// bangumi/manga/fikushon shapes. Unwrap it to the single shape that matches
/// the extension's declared @type so the existing typed readers can consume it.
dynamic unwrapAll(dynamic data, ExtensionType type) {
  if (data is! pb_extension.ExtensionAllWatch) return data;
  switch (type) {
    case ExtensionType.bangumi:
      return data.bangumi;
    case ExtensionType.manga:
      return data.manga;
    case ExtensionType.fikushon:
      return data.fikushon;
    case ExtensionType.all:
      // No single declared shape; prefer bangumi, then manga, then fikushon.
      if (data.hasBangumi()) return data.bangumi;
      if (data.hasManga()) return data.manga;
      if (data.hasFikushon()) return data.fikushon;
      return data;
  }
}
