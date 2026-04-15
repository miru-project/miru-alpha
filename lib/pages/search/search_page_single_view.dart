import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/pages/search/widget/desktop_search_filter_box.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/utils/hook/sheet_controller.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/widgets/error.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:miru_alpha/pages/search/widget/mobile_search_single_filter_box.dart';
import 'package:miru_alpha/pages/search/widget/search_grid_loading.dart';
import 'package:miru_alpha/pages/search/widget/search_grid_view.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class SearchPageSingleView extends HookConsumerWidget {
  const SearchPageSingleView({super.key, this.query, required this.meta});
  final String? query;
  final ExtensionMeta meta;
  @override
  Widget build(context, ref) {
    final showPageNumber = MiruSettings.getSettingSync<bool>(
      SettingKey.showPageNumber,
    );
    final sheetController = useSheetController();
    final scrollController = useScrollController();
    useEffect(() {
      Future.microtask(() {
        ref
            .read(searchPageSingleProviderProvider.notifier)
            .setPkg(meta.packageName);
        ref
            .read(searchPageSingleProviderProvider.notifier)
            .fetchInitialFilters();
      });
      return null;
    }, [meta.packageName]);
    return MiruScaffold(
      sheetController: sheetController,
      mobileHeader: Padding(
        padding: EdgeInsetsGeometry.only(bottom: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 4, left: 10),
                child: Icon(
                  FIcons.chevronLeft,
                  size: 28,
                  color: context.theme.colors.primary,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: showPageNumber ? 20 : 22,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (MiruSettings.getSettingSync(SettingKey.showPageNumber))
                  Consumer(
                    builder: (context, ref, _) {
                      final page = ref.watch(
                        searchPageSingleProviderProvider.select((v) => v.page),
                      );
                      return Text(
                        'page: ${page.toString()}',
                        style: TextStyle(fontSize: 13),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      snappingOffsets: [
        AbsoluteSheetOffset(150),
        ProportionalToViewportSheetOffset(0.55),
        ProportionalToViewportSheetOffset(1.0),
      ],
      snapSheet: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: MobileSearchSingleFilterBox(
            meta: meta,
            sheetController: sheetController,
          ),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, cons) {
          final state = ref.watch(searchPageSingleProviderProvider);
          final snapshot = ref.watch(
            fetchExtensionSearchLatestProvider.call(
              meta.packageName,
              1,
              query: state.query,
              filterJson: state.appliedFilterJson,
            ),
          );

          return snapshot.when(
            data: (data) {
              return PlatformWidget(
                desktopWidget: Stack(
                  children: [
                    SearchGridView(
                      meta: meta,
                      scrollController: scrollController,
                      cons: cons,
                      res: data,
                    ),
                    DesktopSearchSingleFilterBox(meta: meta),
                  ],
                ),
                mobileWidget: SearchGridView(
                  meta: meta,
                  scrollController: scrollController,
                  cons: cons,
                  res: data,
                ),
              );
              // return ;
            },
            error: (err, stack) => ErrorDisplay.grpc(err: err, stack: stack),
            loading: () => PlatformWidget(
              mobileWidget: MobileSeachGridLoadingWidget(
                scrollController: scrollController,
              ),
              desktopWidget: SearchGridLoadingWidget(
                scrollController: scrollController,
              ),
            ),
          );
        },
      ),
    );
  }
}
