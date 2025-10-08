import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/widgets/gridView/index.dart';

class SearchGridView extends StatelessWidget {
  final int page;
  final List<ExtensionListItem> result;
  final BoxConstraints cons;
  final ScrollController scrollController;
  // final bool isLoading;
  final ExtensionMeta meta;
  const SearchGridView({
    super.key,
    required this.scrollController,
    required this.cons,
    required this.page,
    required this.meta,
    required this.result,
    // required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // final loading = isLoading;
    // if (isLoading) {
    //   final truncateDivison = cons.maxWidth ~/ 110;
    //   final loadingWidgetCount =
    //       truncateDivison * 2 - value.length % truncateDivison;
    //   debugPrint(loadingWidgetCount.toString());
    //   return MiruGridView(
    //     scrollController: scrollController,
    //     mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: cons.maxWidth ~/ 110,
    //       childAspectRatio: 0.6,
    //     ),
    //     desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: cons.maxWidth ~/ 180,
    //       childAspectRatio: 0.6,
    //     ),
    //     itemBuilder: (context, index) {
    //       if (index >= value.length) {
    //         return const MiruGridTileLoadingBox();
    //       }
    //       return MiruGridTile(
    //         title: value[index].title,
    //         imageUrl: value[index].cover,
    //         subtitle: value[index].update ?? '',
    //       );
    //     },
    //     itemCount: value.length + loadingWidgetCount,
    //   );
    // }
    return MiruGridView(
      paddingHeightOffest: 50,
      scrollController: scrollController,
      mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cons.maxWidth ~/ 110,
        childAspectRatio: 0.6,
      ),
      desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cons.maxWidth ~/ 200,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) => MiruGridTile(
        onTap: () {
          context.push(
            '/search/single/detail',
            extra: DetailParam(meta: meta, url: result[index].url),
          );
        },
        title: result[index].title,
        imageUrl: result[index].cover,
        subtitle: result[index].update ?? '',
      ),
      itemCount: result.length,
    );
  }
}
