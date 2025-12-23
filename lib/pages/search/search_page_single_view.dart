import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/search_page_single_provider.dart';
import 'package:miru_app_new/utils/setting_dir_index.dart';
import 'package:miru_app_new/pages/search/widget/search_filter_card.dart';
import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/pages/search/widget/search_grid_loading.dart';
import 'package:miru_app_new/pages/search/widget/search_grid_view.dart';

class SearchPageSingleView extends StatefulHookConsumerWidget {
  const SearchPageSingleView({super.key, this.query, required this.meta});
  final String? query;
  final ExtensionMeta meta;
  @override
  createState() => _SearchPageSingleViewState();
}

class _SearchPageSingleViewState extends ConsumerState<SearchPageSingleView>
    with TickerProviderStateMixin {
  late final _scrollController = ScrollController();
  late TabController tabController;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final showPageNumber = MiruSettings.getSettingSync<bool>(
      SettingKey.showPageNumber,
    );
    return MiruScaffold(
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
                  widget.meta.name,
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
      snapSheet: [
        FCard.raw(
          child: FTextField(
            maxLines: 1,
            onSubmit: (value) {
              ref.invalidate(
                fetchExtensionSearchLatestProvider.call(
                  widget.meta.packageName,
                  1,
                  query: value,
                ),
              );
              ref
                  .read(searchPageSingleProviderProvider.notifier)
                  .setQuery(value);
              // final page = ref.watch(
              //   searchPageSingleProviderProvider.select((e) => e.page),
              // );
              // ref.read(
              //   fetchExtensionSearchLatestProvider.call(
              //     widget.meta.packageName,
              //     page,
              //     query: value,
              //   ),
              // );
            },
            hint: "Search by Name or Tags ...",
            prefixBuilder: (context, style, states) => Padding(
              padding: EdgeInsetsGeometry.only(left: 12, right: 10),
              child: Icon(FIcons.search),
            ),
          ),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, cons) {
          final query = ref.watch(
            searchPageSingleProviderProvider.select((v) => v.query),
          );
          final snapshot = ref.watch(
            fetchExtensionSearchLatestProvider.call(
              widget.meta.packageName,
              1,
              query: query,
            ),
          );

          return snapshot.when(
            data: (data) {
              return PlatformWidget(
                desktopWidget: Stack(
                  children: [
                    SearchGridView(
                      meta: widget.meta,
                      scrollController: _scrollController,
                      cons: cons,
                      res: data,
                    ),
                    DesktopSearchSingleFilterBox(meta: widget.meta),
                  ],
                ),
                mobileWidget: SearchGridView(
                  meta: widget.meta,
                  scrollController: _scrollController,
                  cons: cons,
                  res: data,
                ),
              );
              // return ;
            },
            error: (err, stack) => ErrorDisplay.grpc(err: err, stack: stack),
            loading: () => PlatformWidget(
              mobileWidget: MobileSeachGridLoadingWidget(
                scrollController: _scrollController,
              ),
              desktopWidget: SearchGridLoadingWidget(
                scrollController: _scrollController,
              ),
            ),
          );
        },
      ),
    );
  }
}

class DesktopSearchSingleFilterBox extends ConsumerWidget {
  const DesktopSearchSingleFilterBox({super.key, required this.meta});
  final ExtensionMeta meta;
  void refresh(WidgetRef ref) {
    ref.invalidate(fetchExtensionSearchLatestProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    return SizedBox(
      height: 75,
      child: SearchFilterCard(
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: FTextField(
                control: .managed(initial: TextEditingValue(text: state.query)),
                // initialText: state.query,
                prefixBuilder: (context, style, states) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4),
                    child: Icon(FIcons.search),
                  );
                },
                suffixBuilder: (context, style, states) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 8),
                    child: FBadge(child: Text('↵')),
                  );
                },
                contextMenuBuilder: (context, editableTextState) {
                  return Column(children: [Text('Custom Context Menu')]);
                },
                hint: 'Search ',
                onSubmit: (value) {
                  // ref
                  //     .read(searchPageSingleProviderProvider.notifier)
                  //     .setQuery(value);
                  // refresh(ref);
                  ref.invalidate(
                    fetchExtensionSearchLatestProvider.call(
                      meta.packageName,
                      1,
                      query: value,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 8),
            FButton.icon(
              onPress: () => refresh(ref),
              child: Icon(FIcons.refreshCcw),
            ),
          ],
        ),
      ),
    );
  }
}
