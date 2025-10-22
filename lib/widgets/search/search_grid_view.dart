import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/provider/search_page_single_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:miru_app_new/widgets/grid_view/index.dart';
import 'package:miru_app_new/widgets/platform_widget.dart';

class SearchGridView extends HookConsumerWidget {
  // final int page;
  final List<ExtensionListItem> res;
  final BoxConstraints cons;
  final ScrollController scrollController;
  // final bool isLoading;
  final ExtensionMeta meta;
  const SearchGridView({
    super.key,
    required this.scrollController,
    required this.cons,
    // required this.page,
    required this.meta,
    required this.res,
    // required this.isLoading,
  });
  final desktopLayoutWidth = 200;
  final mobileLayoutWidth = 110;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int page = 1;
    final resState = useState(res);
    final result = resState.value;
    final isLoading = useState(false);
    void listener() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!isLoading.value) {
          isLoading.value = true;
          final c = ref.watch(searchPageSingleProviderProvider);
          try {
            // Serach Mode
            if (c.query.isNotEmpty) {
              final res = await ExtensionEndpoint.search(
                meta.packageName,
                c.query,
                page + 1,
              );
              if (res.isNotEmpty) {
                resState.value = [...resState.value, ...res];
                // page += 1;
                ref
                    .read(searchPageSingleProviderProvider.notifier)
                    .setPage(page + 1);
              }
              isLoading.value = false;
              return;
            }

            // Latest Mode
            final res = await ExtensionEndpoint.latest(
              meta.packageName,
              page + 1,
            );
            if (res.isNotEmpty) {
              resState.value = [...resState.value, ...res];
              // page += 1;
              ref
                  .read(searchPageSingleProviderProvider.notifier)
                  .setPage(page + 1);
            }
            isLoading.value = false;
          } catch (e) {
            if (e is DioException) {
              iconsMessageToast(
                "Failed to get ${c.query.isEmpty ? "latest" : "search"} on ${meta.name} \n${e.message} ",
                FIcons.octagonX,
              );
            }
          }
        }
      }
    }

    useEffect(() {
      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [page]);

    final axisCnt = DeviceUtil.isMobileLayout(context)
        ? 2
        : cons.maxWidth ~/ 200;
    final remain = result.length % axisCnt;
    final remainLoading = remain == 0 ? axisCnt : axisCnt - remain;

    return PlatformWidget(
      desktopWidget: MiruGridView(
        paddingHeightOffest: 50,
        scrollController: scrollController,
        mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: axisCnt,
          childAspectRatio: 0.6,
        ),
        desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: axisCnt,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          if (isLoading.value && index >= result.length) {
            return const MiruGridTileLoadingBox();
          }
          return MiruDesktopGridTile(
            onTap: () {
              context.push(
                '/search/single/detail',
                extra: DetailParam(meta: meta, url: result[index].url),
              );
            },
            title: result[index].title,
            imageUrl: result[index].cover,
            subtitle: result[index].update ?? '',
          );
        },
        itemCount: isLoading.value
            ? result.length + remainLoading
            : result.length,
      ),
      mobileWidget: MiruGridView(
        paddingHeightOffest: 50,
        scrollController: scrollController,
        mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: axisCnt,
          childAspectRatio: 0.6,
        ),
        desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: axisCnt,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          if (isLoading.value && index >= result.length) {
            return const MiruGridTileLoadingBox();
          }
          return MiruMobileTile(
            onTap: () {
              context.push(
                '/search/single/detail',
                extra: DetailParam(meta: meta, url: result[index].url),
              );
            },
            title: result[index].title,
            imageUrl: result[index].cover,
            subtitle: result[index].update ?? '',
          );
        },
        itemCount: isLoading.value
            ? result.length + remainLoading
            : result.length,
      ),
    );
  }
}
