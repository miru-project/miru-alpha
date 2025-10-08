import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/search_page_single_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/widgets/core/search_filter_card.dart';
import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/widgets/search/search_grid_loading.dart';
import 'package:miru_app_new/widgets/search/search_grid_view.dart';

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
  void initState() {
    super.initState();
    // initialize provider-backed state
    // final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    // notifier.setQuery(widget.query ?? '');
    // notifier.setLoading(true);
    // notifier.setPage(1);

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   // final filter = await ExtensionEndpoint.createFilter(
    //   //   widget.meta.packageName,
    //   // );
    //   // tabController = TabController(length: filter.length, vsync: this);
    //   // notifier.addFileNotifier(filter);
    //   // notifier.initializeSelected(filter.length);
    //   // notifier.setIsUpdateFilter(true);
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    // final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    final isFilterActivate = useState(false);
    // tabController = useState(useTabController(initialLength: 0));
    final isUpdateFilter = ref.watch(
      searchPageSingleProviderProvider.select((value) => value.isUpdateFilter),
    );
    return MiruScaffold(
      snapSheet: (DeviceUtil.getWidth(context) < 800)
          //mobile
          ? <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  onPress: () {
                    context.pop();
                  },
                  prefix: const Icon(FIcons.chevronLeft),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.meta.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final page = ref.watch(
                            searchPageSingleProviderProvider.select(
                              (v) => v.page,
                            ),
                          );
                          return Text('page: ${page.toString()}');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // SideBarSearchBar(
              //   trailing: Row(
              //     children: [
              //       FButton.icon(
              //         child: const Icon(FIcons.x),
              //         onPress: () {
              //           final notifier = ref.read(
              //             searchPageSingleProviderProvider.notifier,
              //           );
              //           notifier.setQuery('');
              //           notifier.setPage(1);
              //           ref.invalidate(
              //             fetchExtensionLatestProvider(
              //               widget.meta.packageName,
              //               ref.read(searchPageSingleProviderProvider).page,
              //             ),
              //           );
              //           ref.read(
              //             fetchExtensionLatestProvider(
              //               widget.meta.packageName,
              //               ref.read(searchPageSingleProviderProvider).page,
              //             ),
              //           );
              //           notifier.clearResult();
              //           notifier.setLoading(true);
              //         },
              //       ),
              //       FButton.icon(
              //         onPress: () {
              //           isFilterActivate.value = !isFilterActivate.value;
              //         },
              //         child: isFilterActivate.value
              //             ? Icon(
              //                 Icons.filter_alt,
              //                 // color: context
              //                 //     .moonTheme
              //                 //     ?.segmentedControlTheme
              //                 //     .colors
              //                 //     .backgroundColor,
              //               )
              //             : const Icon(Icons.filter_alt_off_outlined),
              //       ),
              //     ],
              //   ),
              //   onsubmitted: (val) {
              //     if (val.isEmpty) return;
              //     final notifier = ref.read(
              //       searchPageSingleProviderProvider.notifier,
              //     );
              //     notifier.setQuery(val);
              //     notifier.setPage(1);
              //     ref.invalidate(
              //       fetchExtensionSearchProvider(
              //         widget.meta.packageName,
              //         ref.read(searchPageSingleProviderProvider).query,
              //         ref.read(searchPageSingleProviderProvider).page,
              //       ),
              //     );
              //     ref.read(
              //       fetchExtensionSearchProvider(
              //         widget.meta.packageName,
              //         ref.read(searchPageSingleProviderProvider).query,
              //         ref.read(searchPageSingleProviderProvider).page,
              //       ),
              //     );
              //     notifier.clearResult();
              //     notifier.setLoading(true);
              //   },
              // ),
              const SizedBox(height: 10),
              if (isUpdateFilter) ...[
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: MoonTabBar(
                //     tabController: tabController,
                //     tabs: List.generate(
                //       ref.watch(searchPageSingleProviderProvider).fileNotifier.length,
                //       (index) => MoonTab(
                //         label: Text(
                //           ref
                //               .watch(searchPageSingleProviderProvider)
                //               .fileNotifier
                //               .keys
                //               .toList()[index],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 1000,
                //   child: TabBarView(
                //     controller: tabController,
                //     children: List.generate(
                //       searchProvider.fileNotifier.length,
                //       (index) {
                //         final fileMap = searchProvider.fileNotifier;
                //         final keys = fileMap.keys.toList();
                //         final defaultOpt =
                //             fileMap[keys[index]]?.defaultOption ?? '';

                //         final selectOptions =
                //             fileMap[keys[index]]?.options.values.toList() ?? [];
                //         {
                //           if (selectOptions.contains(defaultOpt)) {
                //             final initIndex = selectOptions.indexOf(defaultOpt);
                //             notifier.setSelectedIndex(index, [initIndex]);
                //           }
                //         }
                //         return CatergoryGroupChip(
                //           maxSelected: fileMap[keys[index]]?.max,
                //           minSelected: fileMap[keys[index]]?.min,
                //           initSelected: searchProvider.selected.length > index
                //               ? searchProvider.selected[index]
                //               : [],
                //           items:
                //               fileMap[keys[index]]?.options.values.toList() ??
                //               [],
                //           onpress: (val) {
                //             notifier.setSelectedIndex(index, val);
                //           },
                //         );
                //       },
                //     ),
                //   ),
                // ),
              ],
            ]
          : <Widget>[],
      body: LayoutBuilder(
        builder: (context, cons) => Consumer(
          builder: (context, cref, _) {
            return contentWithRef(context, cons);
          },
        ),
      ),
    );
  }

  void refresh() {
    ref.invalidate(fetchExtensionSearchLatestProvider);
    final state = ref.watch(searchPageSingleProviderProvider);
    ref.read(
      fetchExtensionSearchLatestProvider.call(
        widget.meta.packageName,
        state.page,
        query: state.query,
      ),
    );
  }

  Widget contentWithRef(
    // WidgetRef localRef,
    BuildContext context,
    BoxConstraints cons,
  ) {
    final state = ref.watch(searchPageSingleProviderProvider);
    // AsyncValue<List<ExtensionListItem>> snapshot;
    final snapshot = ref.watch(
      fetchExtensionSearchLatestProvider.call(
        widget.meta.packageName,
        state.page,
        query: state.query,
      ),
    );

    return EasyRefresh(
      scrollController: _scrollController,
      onLoad: () async {
        logger.info('load');
      },
      footer: const ClassicFooter(),
      child: snapshot.when(
        data: (data) {
          return Stack(
            children: [
              SearchGridView(
                meta: widget.meta,
                scrollController: _scrollController,
                cons: cons,
                page: state.page,
                result: data,
              ),
              SizedBox(
                height: 75,
                child: SearchFilterCard(
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: FTextField(
                          prefixBuilder: (context, style, states) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 4,
                              ),
                              child: Icon(FIcons.search),
                            );
                          },
                          suffixBuilder: (context, style, states) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 4.0,
                                right: 8,
                              ),
                              child: FBadge(child: Text('↵')),
                            );
                          },
                          contextMenuBuilder: (context, editableTextState) {
                            return Column(
                              children: [Text('Custom Context Menu')],
                            );
                          },
                          hint: 'Search ',
                          onSubmit: (value) {
                            ref
                                .read(searchPageSingleProviderProvider.notifier)
                                .setQuery(value);
                            refresh();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      FButton.icon(
                        onPress: () => refresh(),
                        child: Icon(FIcons.refreshCcw),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (err, stack) => ErrorDisplay.network(err: err, stack: stack),
        loading: () =>
            SearchGridLoadingWidget(scrollController: _scrollController),
      ),
    );
  }
}
