import 'dart:async';
import 'dart:io';

import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/utils/network/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/watch_result.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
part 'extension_provider.g.dart';

/// Thrown when the V2 watch call resolved the mirror groups but resolving
/// the chosen mirror failed. Carries the resolved [v2watch] so the error UI
/// can offer the remaining mirrors as a fallback ("Switch Mirror").
class WatchMirrorException implements Exception {
  const WatchMirrorException(this.v2watch, this.cause);

  final pb_extension.ExtensionWatch v2watch;
  final Object cause;

  @override
  String toString() => 'Mirror resolution failed: $cause';
}

@riverpod
Future<WatchResult> watch(
  Ref ref,
  String watchUrl,
  String detailUrl,
  ExtensionMeta meta, {
  String? mirrorUrl,
}) async {
  try {
    // Get download info if exists
    final downloaded = await MiruGrpcClient.downloadClient
        .getDownloadByPackageWatchUrlDetailUrl(
          proto.GetDownloadByPackageWatchUrlDetailUrlRequest(
            package: meta.packageName,
            watchUrl: watchUrl,
            detailUrl: detailUrl,
          ),
        );
    final savePath = downloaded.download.savePath;
    final isExists = File(savePath).existsSync();
    if (isExists) {
      return WatchResult(data: downloaded.download);
    }
    throw Exception('Download file not found');
  } catch (e) {
    var watchResult = await MiruCoreEndpoint.watch(
      watchUrl,
      meta.packageName,
      meta,
    );
    if (meta.api == "2" && watchResult is pb_extension.ExtensionWatch) {
      if (watchResult.groups.isNotEmpty) {
        final group = watchResult.groups.firstWhere(
          (e) =>
              watchResult.hasDefaultGroup() &&
              e.title == watchResult.defaultGroup,
          orElse: () => watchResult.groups.first,
        );
        if (group.mirrors.isNotEmpty) {
          pb_extension.ExtensionMirror mirror;
          if (mirrorUrl != null) {
            mirror = group.mirrors.firstWhere(
              (m) => m.url == mirrorUrl,
              orElse: () => group.mirrors.first,
            );
          } else {
            final index = watchResult.hasDefaultIndex()
                ? watchResult.defaultIndex
                : 0;
            mirror = (index >= 0 && index < group.mirrors.length)
                ? group.mirrors[index]
                : group.mirrors.first;
          }

          // Call mirror which now returns the specialized mirror object
          try {
            final resolved = await MiruCoreEndpoint.mirror(
              meta.packageName,
              mirror.url,
            );
            return WatchResult(data: resolved, v2watch: watchResult);
          } catch (e) {
            // The mirror list itself resolved — surface it so the error UI
            // can offer another mirror instead of a dead-end retry.
            throw WatchMirrorException(watchResult, e);
          }
        }
      }
      throw Exception("Can't find mirror link in extension V2");
    }

    return WatchResult(data: watchResult);
  }
}

@riverpod
Future<List<ExtensionRepo>> fetchExtensionRepo(Ref ref) async {
  final result = await GithubNetwork.fetchRepo();
  return result;
}

Future<Detail?> fetchDetailFromExtension(String pkg, String url) async {
  final data = await MiruCoreEndpoint.detail(pkg, url);

  await MiruCoreEndpoint.upsertDbDetail(data);
  return data;
}

Future<Detail?> fetchDetailFromDb(String pkg, String detailUrl) async {
  final dbDetail = await MiruCoreEndpoint.getDbDetail(pkg, detailUrl);
  if (dbDetail != null) {
    return dbDetail;
  } else {
    return null;
  }
}

@riverpod
Future<Detail> fetchDetail(
  Ref ref,
  String pkg,
  String url, {
  bool force = false,
}) async {
  if (force) {
    final detail = await fetchDetailFromExtension(pkg, url);
    return detail!;
  }
  final detail =
      await fetchDetailFromDb(pkg, url) ??
      await fetchDetailFromExtension(pkg, url);
  return detail!;
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionLatest(
  Ref ref,
  String pkg,
  int page,
) async {
  return await MiruCoreEndpoint.latest(pkg, page);
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionSearch(
  Ref ref,
  String package,
  String query,
  int page, {
  proto.FilterSelection? filter,
}) async {
  final result = await MiruCoreEndpoint.search(
    package,
    query,
    page,
    filter: filter,
  );
  return result;
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionSearchLatest(
  Ref ref,
  String package,
  int page, {
  String? query,
  proto.FilterSelection? filter,
}) async {
  final hasFilter =
      filter?.selections.values.any(
        (v) => v.values.where((e) => e.isNotEmpty).isNotEmpty,
      ) ??
      false;
  if ((query == null || query.isEmpty) && !hasFilter) {
    final result = await MiruCoreEndpoint.latest(package, page);
    return result;
  }
  final result = await MiruCoreEndpoint.search(
    package,
    query ?? "",
    page,
    filter: filter,
  );
  return result;
}
