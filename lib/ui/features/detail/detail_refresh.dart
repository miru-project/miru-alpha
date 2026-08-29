// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/detial_provider.dart';
import 'dart:convert';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Force refresh detail from extension (web).
/// Fetches fresh data from extension, saves to DB on success, shows toast and keeps old data on failure.
Future<void> forceRefreshDetail(
  WidgetRef ref,
  String detailUrl,
  ExtensionMeta meta,
) async {
  final provider = detialProvider(detailUrl, meta: meta);
  final state = ref.read(provider);
  final retryToken = state.retryToken;

  // Bump retry token
  ref.read(provider.notifier).state = state.copyWith(
    lastError: null,
    retryToken: retryToken + 1,
  );

  debugPrint(
    '[DetailPage] forceRefreshDetail called for ${meta.packageName} $detailUrl',
  );

  try {
    // Fetch fresh data from extension (web)
    final resp = await MiruGrpcClient.extensionClient.detail(
      proto.DetailRequest()
        ..pkg = meta.packageName
        ..url = detailUrl,
    );
    debugPrint('[DetailPage] forceRefreshDetail extension response received');

    final extDetail = resp.data;
    // Save fresh data to DB
    await MiruGrpcClient.dbClient.upsertDetail(
      proto.UpsertDetailRequest()
        ..title = extDetail.title
        ..cover = extDetail.cover
        ..desc = extDetail.desc
        ..detailUrl = detailUrl
        ..package = meta.packageName
        ..episodes = jsonEncode(
          extDetail.episodes.map((e) => e.toProto3Json()).toList(),
        )
        ..headers = '',
    );
    debugPrint('[DetailPage] forceRefreshDetail data saved to DB');

    final newDetail = proto.Detail()
      ..title = extDetail.title
      ..cover = extDetail.cover
      ..desc = extDetail.desc
      ..detailUrl = detailUrl
      ..package = meta.packageName;
    if (extDetail.episodes.isNotEmpty) {
      final episodesJson = extDetail.episodes
          .map((e) => e.toProto3Json())
          .toList();
      newDetail.episodes = jsonEncode(episodesJson);
    }

    ref.read(detialProvider(detailUrl, meta: meta).notifier).state = state
        .copyWith(
          detailInfo: newDetail,
          status: DetialStatus.ready,
          lastError: null,
          toastMessage: 'common.force_refresh_success'.i18n,
        );
  } catch (e, st) {
    debugPrint('[DetailPage] forceRefreshDetail error: $e\n$st');
    _handleForceRefreshFailureDetail(ref, detailUrl, meta, e.toString());
  }
}

void _handleForceRefreshFailureDetail(
  WidgetRef ref,
  String detailUrl,
  ExtensionMeta meta,
  String errorMsg,
) {
  final provider = detialProvider(detailUrl, meta: meta);
  final state = ref.read(provider);
  if (state.detailInfo != null) {
    // Keep cached data, show toast, don't switch to error state
    ref.read(detialProvider(detailUrl, meta: meta).notifier).state = state
        .copyWith(
          toastMessage: 'common.force_refresh_failed_using_cache'.i18n,
          lastError: errorMsg,
        );
  } else {
    // No cached data - show error state
    ref.read(detialProvider(detailUrl, meta: meta).notifier).state = state
        .copyWith(
          status: DetialStatus.error,
          lastError: errorMsg,
          toastMessage: errorMsg,
        );
  }
}
