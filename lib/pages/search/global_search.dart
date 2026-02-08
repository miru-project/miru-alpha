import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/search_page_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/widgets/grid_view/miru_grid_tile.dart';

class GlobalSearch extends HookConsumerWidget {
  const GlobalSearch({
    super.key,
    required this.searchQuery,
    required this.isMobile,
  });
  final String searchQuery;
  final bool isMobile;

  Widget _buildDesktopTile(
    AsyncValue<List<ExtensionListItem>> snapshot,
    ExtensionMeta meta,
  ) {
    return snapshot.when(
      data: (data) {
        return SizedBox(
          height: 330,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final ext = data.elementAt(index);
              return MiruDesktopGridTile(
                onTap: () {
                  context.push(
                    '/search/single/detail',
                    extra: DetailParam(meta: meta, url: ext.url),
                  );
                },
                width: 200,
                title: ext.title,
                subtitle: ext.update ?? '',
                imageUrl: ext.cover,
              );
            },
            itemCount: data.length,
          ),
        );
      },
      error: (error, stack) {
        return ErrorDisplay.grpc(err: error, stack: stack);
      },
      loading: () {
        return const Center(child: FCircularProgress());
      },
    );
  }

  Widget _buildMobileTile(
    AsyncValue<List<ExtensionListItem>> snapshot,
    ExtensionMeta meta,
  ) {
    return snapshot.when(
      data: (data) {
        return SizedBox(
          height: 200,

          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final ext = data.elementAt(index);
              return Padding(
                padding: .symmetric(horizontal: 10),
                child: MiruMobileTile(
                  onTap: () {
                    context.push(
                      '/search/single/detail',
                      extra: DetailParam(meta: meta, url: ext.url),
                    );
                  },
                  width: 130,
                  title: ext.title,
                  subtitle: ext.update ?? '',
                  imageUrl: ext.cover,
                ),
              );
            },
            itemCount: data.length,
          ),
        );
      },
      error: (error, stack) {
        return ErrorDisplay.grpc(err: error, stack: stack);
      },
      loading: () {
        return const Center(child: FCircularProgress());
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaData = ref.watch(searchPageProvider.select((e) => e.metaData));
    final existedPinnedExtensions = ref.watch(
      searchPageProvider.select((e) => e.existedPinnedExtensions),
    );
    final listPadding = isMobile ? 0.0 : 200.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: ListView.builder(
            padding: .symmetric(vertical: listPadding),
            itemBuilder: (context, index) {
              final snapshot = ref.watch(
                fetchExtensionSearchLatestProvider.call(
                  existedPinnedExtensions.elementAt(index),
                  1,
                  query: searchQuery,
                ),
              );
              final meta = metaData
                  .where(
                    (ext) =>
                        ext.packageName ==
                        existedPinnedExtensions.elementAt(index),
                  )
                  .first;

              return SizedBox(
                height: isMobile ? 265.0 : 360.0,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(height: 10),
                    FButton(
                      mainAxisSize: .min,
                      style: FButtonStyle.ghost(),
                      onPress: () {
                        context.push(
                          '/search/single',
                          extra: SearchPageParam(meta: meta),
                        );
                      },
                      suffix: Icon(FIcons.chevronRight),
                      child: Text(
                        meta.name,
                        style: TextStyle(fontWeight: .bold, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (isMobile)
                      _buildMobileTile(snapshot, meta)
                    else
                      _buildDesktopTile(snapshot, meta),
                  ],
                ),
              );
            },
            itemCount: existedPinnedExtensions.length,
          ),
        );
      },
    );
  }
}
