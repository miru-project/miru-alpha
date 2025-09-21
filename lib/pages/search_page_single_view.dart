import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/widgets/gridView/index.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:go_router/go_router.dart';

class SearchPageSingleView extends StatefulHookConsumerWidget {
  const SearchPageSingleView({super.key, this.query, required this.meta});
  final String? query;
  final ExtensionMeta meta;
  @override
  createState() => _SearchPageSingleViewState();
}

class _SearchPageSingleViewState extends ConsumerState<SearchPageSingleView>
    with TickerProviderStateMixin {
  late final ValueNotifier<String> _query;
  late final ValueNotifier<int> _page;
  final ValueNotifier<List<ExtensionListItem>> _result = ValueNotifier([]);
  late final _scrollController = ScrollController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  // late final Map<String, ExtensionFilter> _filters;
  late ValueNotifier<Map<String, ExtensionFilter>> _fileNotifier;
  late ValueNotifier<bool> _isUpdateFilter;
  late TabController tabController;
  late final ValueNotifier<List<List<int>>> _selected;

  @override
  void initState() {
    _query = ValueNotifier(widget.query ?? '');
    _isLoading.value = true;
    _page = ValueNotifier(1);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final filter = await ExtensionEndpoint.createFilter(
        widget.meta.packageName,
      );
      tabController = TabController(length: filter.length, vsync: this);
      _fileNotifier.value.addAll(filter);
      _selected = ValueNotifier(List.generate(filter.length, (index) => []));
      _isUpdateFilter.value = true;
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void indexToFilterParam() {}
  @override
  Widget build(context) {
    _fileNotifier = useState({});
    _isUpdateFilter = useState(false);
    final isFilterActivate = useState(false);
    // tabController = useState(useTabController(initialLength: 0));

    return MiruScaffold(
      sidebar:
          (DeviceUtil.getWidth(context) < 800)
              //mobile
              ? <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: MoonButton(
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.meta.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _page,
                          builder: (context, value, _) => Text('page: $value'),
                        ),
                      ],
                    ),
                    onTap: () {
                      context.pop();
                    },
                    leading: const Icon(
                      MoonIcons.controls_chevron_left_16_regular,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SideBarSearchBar(
                  trailing: Row(
                    children: [
                      MoonButton.icon(
                        icon: const Icon(MoonIcons.controls_close_24_regular),
                        onTap: () {
                          _query.value = '';
                          _page.value = 1;
                          ref.invalidate(
                            fetchExtensionLatestProvider(
                              widget.meta.packageName,
                              _page.value,
                            ),
                          );
                          ref.read(
                            fetchExtensionLatestProvider(
                              widget.meta.packageName,
                              _page.value,
                            ),
                          );
                          _result.value = [];
                          _isLoading.value = true;
                        },
                      ),
                      MoonButton.icon(
                        onTap: () {
                          isFilterActivate.value = !isFilterActivate.value;
                        },
                        icon:
                            isFilterActivate.value
                                ? Icon(
                                  Icons.filter_alt,
                                  color:
                                      context
                                          .moonTheme
                                          ?.segmentedControlTheme
                                          .colors
                                          .backgroundColor,
                                )
                                : const Icon(Icons.filter_alt_off_outlined),
                      ),
                    ],
                  ),
                  onsubmitted: (val) {
                    if (val.isEmpty) return;

                    _query.value = val;
                    _page.value = 1;
                    ref.invalidate(
                      fetchExtensionSearchProvider(
                        widget.meta.packageName,
                        _query.value,
                        _page.value,
                      ),
                    );
                    ref.read(
                      fetchExtensionSearchProvider(
                        widget.meta.packageName,
                        _query.value,
                        _page.value,
                      ),
                    );
                    _result.value = [];
                    _isLoading.value = true;
                  },
                ),
                const SizedBox(height: 10),
                if (_isUpdateFilter.value) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: MoonTabBar(
                      tabController: tabController,
                      tabs: List.generate(
                        _fileNotifier.value.length,
                        (index) => MoonTab(
                          label: Text(_fileNotifier.value.keys.toList()[index]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1000,
                    child: TabBarView(
                      controller: tabController,
                      children: List.generate(_fileNotifier.value.length, (
                        index,
                      ) {
                        final keys = _fileNotifier.value.keys.toList();
                        final defaultOpt =
                            _fileNotifier.value[keys[index]]?.defaultOption ??
                            '';

                        final map = _fileNotifier.value;
                        final selectOptions =
                            _fileNotifier.value[keys[index]]?.options.values
                                .toList() ??
                            [];
                        {
                          if (selectOptions.contains(defaultOpt)) {
                            final initIndex = selectOptions.indexOf(defaultOpt);
                            _selected.value[index] = [initIndex];
                          }
                        }
                        return CatergoryGroupChip(
                          maxSelected: _fileNotifier.value[keys[index]]?.max,
                          minSelected: _fileNotifier.value[keys[index]]?.min,
                          initSelected: _selected.value[index],
                          items: map[keys[index]]!.options.values.toList(),
                          onpress: (val) {
                            final newSelected = List<List<int>>.from(
                              _selected.value,
                            );
                            newSelected[index] = val;
                            _selected.value = newSelected;
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ]
              : <Widget>[
                const SideBarListTitle(title: '主页'),
                SideBarSearchBar(
                  onsubmitted: (val) {
                    _query.value = val;
                    _page.value = 1;
                  },
                ),
                const SizedBox(height: 10),
                SidebarExpander(
                  title: "歷史",
                  expanded: true,
                  child: CategoryGroup(
                    needSpacer: false,
                    items: const ['全部'],
                    onpress: (val) {},
                  ),
                ),
                SidebarExpander(
                  title: "分类",
                  expanded: true,
                  child: CategoryGroup(
                    needSpacer: false,
                    items: const ['全部', '影視', '漫畫', '小說'],
                    onpress: (val) {},
                  ),
                ),
                const SizedBox(height: 10),
                SidebarExpander(
                  title: '收藏夹',
                  actions: [
                    Button(
                      onPressed: () {},
                      child: const Icon(Icons.add, size: 15),
                    ),
                  ],
                  expanded: true,
                  child: CategoryGroup(
                    needSpacer: false,
                    items: const ['全部'],
                    onpress: (val) {},
                  ),
                ),
              ],
      body: LayoutBuilder(builder: (context, cons) => content(context, cons)),
    );
  }

  Widget content(BuildContext context, BoxConstraints cons) {
    if (_query.value.isEmpty) {
      final snapshot = ref.watch(
        fetchExtensionLatestProvider(widget.meta.packageName, _page.value),
      );
      return EasyRefresh(
        scrollController: _scrollController,
        onLoad: () async {
          debugPrint('load');
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
            if (_isLoading.value) {
              _result.value.addAll(data);
              _isLoading.value = false;
            }
            return _GridView(
              meta: widget.meta,
              scrollController: _scrollController,
              cons: cons,
              query: _query,
              page: _page,
              result: _result,
              isLoading: _isLoading,
            );
          },
          error: (err, stack) => ErrorDisplay.network(err: err, stack: stack),
          loading:
              () => _GridLoadingWidget(scrollController: _scrollController),
        ),
      );
    }
    final snapshot = ref.watch(
      fetchExtensionSearchProvider(
        widget.meta.packageName,
        _query.value,
        _page.value,
      ),
    );
    return EasyRefresh(
      scrollController: _scrollController,
      onLoad: () async {
        logger.info('load');
        if (_isLoading.value) return;
        _isLoading.value = true;
        final data = await ExtensionEndpoint.search(
          widget.meta.packageName,
          _query.value,
          _page.value,
        );
        _result.value.addAll(data);
        _isLoading.value = false;
        _page.value++;
      },
      footer: const ClassicFooter(),
      child: snapshot.when(
        data: (data) {
          if (_isLoading.value) {
            _result.value.addAll(data);
            _isLoading.value = false;
          }
          return _GridView(
            meta: widget.meta,
            scrollController: _scrollController,
            cons: cons,
            query: _query,
            page: _page,
            result: _result,
            isLoading: _isLoading,
          );
        },
        error:
            (e, stack) => Center(
              child: Row(
                children: [Text(e.toString()), Text(stack.toString())],
              ),
            ),
        loading: () => _GridLoadingWidget(scrollController: _scrollController),
      ),
    );
  }
}

class _GridLoadingWidget extends StatelessWidget {
  final ScrollController scrollController;
  const _GridLoadingWidget({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, cons) => MiruGridView(
            scrollController: scrollController,
            mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cons.maxWidth ~/ 110,
              childAspectRatio: 0.6,
            ),
            desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cons.maxWidth ~/ 180,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, index) => const MiruGridTileLoadingBox(),
            itemCount: 20,
          ),
    );
  }
}

class _GridView extends StatelessWidget {
  final ValueNotifier<String> query;
  final ValueNotifier<int> page;
  final ValueNotifier<List<ExtensionListItem>> result;
  final BoxConstraints cons;
  final ScrollController scrollController;
  // late final scrollController = ScrollController();
  // final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isLoading;
  final ExtensionMeta meta;
  const _GridView({
    required this.scrollController,
    required this.cons,
    required this.query,
    required this.page,
    required this.meta,
    required this.result,
    required this.isLoading,
  });
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: result,
      builder: (context, value, _) {
        return ValueListenableBuilder(
          valueListenable: isLoading,
          builder: (conetxt, isLoading, _) {
            if (isLoading) {
              final truncateDivison = cons.maxWidth ~/ 110;
              final loadingWidgetCount =
                  truncateDivison * 2 - value.length % truncateDivison;
              debugPrint(loadingWidgetCount.toString());
              return MiruGridView(
                scrollController: scrollController,
                mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cons.maxWidth ~/ 110,
                  childAspectRatio: 0.6,
                ),
                desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cons.maxWidth ~/ 180,
                  childAspectRatio: 0.6,
                ),
                itemBuilder: (context, index) {
                  if (index >= value.length) {
                    return const MiruGridTileLoadingBox();
                  }
                  return MiruGridTile(
                    title: value[index].title,
                    imageUrl: value[index].cover,
                    subtitle: value[index].update ?? '',
                  );
                },
                itemCount: value.length + loadingWidgetCount,
              );
            }
            return MiruGridView(
              scrollController: scrollController,
              mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cons.maxWidth ~/ 110,
                childAspectRatio: 0.6,
              ),
              desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cons.maxWidth ~/ 180,
                childAspectRatio: 0.65,
              ),
              itemBuilder:
                  (context, index) => MiruGridTile(
                    onTap: () {
                      context.push(
                        '/search/single/detail',
                        extra: DetailParam(meta: meta, url: value[index].url),
                      );
                    },
                    title: value[index].title,
                    imageUrl: value[index].cover,
                    subtitle: value[index].update ?? '',
                  ),
              itemCount: value.length,
            );
          },
        );
      },
    );
  }
}
