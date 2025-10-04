import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/assets.dart';
import 'package:forui/widgets/button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/search_page_single_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/core/log.dart';
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
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    // notifier.setQuery(widget.query ?? '');
    // notifier.setLoading(true);
    // notifier.setPage(1);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final filter = await ExtensionEndpoint.createFilter(
        widget.meta.packageName,
      );
      tabController = TabController(length: filter.length, vsync: this);
      notifier.addFileNotifier(filter);
      notifier.initializeSelected(filter.length);
      notifier.setIsUpdateFilter(true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void indexToFilterParam() {}
  @override
  Widget build(context) {
    // provider-backed state
    final isFilterActivate = useState(false);
    // tabController = useState(useTabController(initialLength: 0));

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
                      Text(
                        'page: ${ref.watch(searchPageSingleProviderProvider).page}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SideBarSearchBar(
                trailing: Row(
                  children: [
                    FButton.icon(
                      child: const Icon(FIcons.x),
                      onPress: () {
                        final notifier = ref.read(
                          searchPageSingleProviderProvider.notifier,
                        );
                        notifier.setQuery('');
                        notifier.setPage(1);
                        ref.invalidate(
                          fetchExtensionLatestProvider(
                            widget.meta.packageName,
                            ref.read(searchPageSingleProviderProvider).page,
                          ),
                        );
                        ref.read(
                          fetchExtensionLatestProvider(
                            widget.meta.packageName,
                            ref.read(searchPageSingleProviderProvider).page,
                          ),
                        );
                        notifier.clearResult();
                        notifier.setLoading(true);
                      },
                    ),
                    FButton.icon(
                      onPress: () {
                        isFilterActivate.value = !isFilterActivate.value;
                      },
                      child: isFilterActivate.value
                          ? Icon(
                              Icons.filter_alt,
                              // color: context
                              //     .moonTheme
                              //     ?.segmentedControlTheme
                              //     .colors
                              //     .backgroundColor,
                            )
                          : const Icon(Icons.filter_alt_off_outlined),
                    ),
                  ],
                ),
                onsubmitted: (val) {
                  if (val.isEmpty) return;
                  final notifier = ref.read(
                    searchPageSingleProviderProvider.notifier,
                  );
                  notifier.setQuery(val);
                  notifier.setPage(1);
                  ref.invalidate(
                    fetchExtensionSearchProvider(
                      widget.meta.packageName,
                      ref.read(searchPageSingleProviderProvider).query,
                      ref.read(searchPageSingleProviderProvider).page,
                    ),
                  );
                  ref.read(
                    fetchExtensionSearchProvider(
                      widget.meta.packageName,
                      ref.read(searchPageSingleProviderProvider).query,
                      ref.read(searchPageSingleProviderProvider).page,
                    ),
                  );
                  notifier.clearResult();
                  notifier.setLoading(true);
                },
              ),
              const SizedBox(height: 10),
              if (ref
                  .watch(searchPageSingleProviderProvider)
                  .isUpdateFilter) ...[
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
                SizedBox(
                  height: 1000,
                  child: TabBarView(
                    controller: tabController,
                    children: List.generate(
                      ref
                          .watch(searchPageSingleProviderProvider)
                          .fileNotifier
                          .length,
                      (index) {
                        final fileMap = ref
                            .watch(searchPageSingleProviderProvider)
                            .fileNotifier;
                        final keys = fileMap.keys.toList();
                        final defaultOpt =
                            fileMap[keys[index]]?.defaultOption ?? '';

                        final selectOptions =
                            fileMap[keys[index]]?.options.values.toList() ?? [];
                        {
                          if (selectOptions.contains(defaultOpt)) {
                            final initIndex = selectOptions.indexOf(defaultOpt);
                            ref
                                .read(searchPageSingleProviderProvider.notifier)
                                .setSelectedIndex(index, [initIndex]);
                          }
                        }
                        return CatergoryGroupChip(
                          maxSelected: fileMap[keys[index]]?.max,
                          minSelected: fileMap[keys[index]]?.min,
                          initSelected:
                              ref
                                      .watch(searchPageSingleProviderProvider)
                                      .selected
                                      .length >
                                  index
                              ? ref
                                    .watch(searchPageSingleProviderProvider)
                                    .selected[index]
                              : [],
                          items: fileMap[keys[index]]!.options.values.toList(),
                          onpress: (val) {
                            ref
                                .read(searchPageSingleProviderProvider.notifier)
                                .setSelectedIndex(index, val);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ]
          : <Widget>[],
      body: LayoutBuilder(builder: (context, cons) => content(context, cons)),
    );
  }

  Widget content(BuildContext context, BoxConstraints cons) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);

    if (state.query.isEmpty) {
      final snapshot = ref.watch(
        fetchExtensionLatestProvider(widget.meta.packageName, state.page),
      );
      return EasyRefresh(
        scrollController: _scrollController,
        onLoad: () async {
          logger.info('load');
          // if (_isLoading.value) return;
          // _isLoading.value = true;
          // final data = await widget.service.latest(_page.value);
          // _result.value.addAll(data);
          // _isLoading.value = false;
          // _page.value++;
        },
        footer: const ClassicFooter(),
        child: snapshot.when(
          data: (data) {
            if (state.isLoading) {
              // notifier.addResult(data);
              // notifier.setLoading(false);
              return SearchGridLoadingWidget(
                scrollController: _scrollController,
              );
            }
            return SearchGridView(
              meta: widget.meta,
              scrollController: _scrollController,
              cons: cons,
              page: state.page,
              result: state.result,
              isLoading: state.isLoading,
            );
          },
          error: (err, stack) => ErrorDisplay.network(err: err, stack: stack),
          loading: () =>
              SearchGridLoadingWidget(scrollController: _scrollController),
        ),
      );
    }
    final snapshot = ref.watch(
      fetchExtensionSearchProvider(
        widget.meta.packageName,
        state.query,
        state.page,
      ),
    );
    return EasyRefresh(
      scrollController: _scrollController,
      onLoad: () async {
        logger.info('load');
        if (state.isLoading) return;
        notifier.setLoading(true);
        final data = await ExtensionEndpoint.search(
          widget.meta.packageName,
          state.query,
          state.page,
        );
        notifier.addResult(data);
        notifier.setLoading(false);
        notifier.incPage();
      },
      footer: const ClassicFooter(),
      child: snapshot.when(
        data: (data) {
          if (state.isLoading) {
            notifier.addResult(data);
            notifier.setLoading(false);
          }
          return SearchGridView(
            meta: widget.meta,
            scrollController: _scrollController,
            cons: cons,
            page: state.page,
            result: state.result,
            isLoading: state.isLoading,
          );
        },
        error: (e, stack) => Center(
          child: Row(children: [Text(e.toString()), Text(stack.toString())]),
        ),
        loading: () =>
            SearchGridLoadingWidget(scrollController: _scrollController),
      ),
    );
  }
}
