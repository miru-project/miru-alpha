import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/pages/setting/setting_general.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/search_page_single_provider.dart';
import 'package:miru_app_new/widgets/search/search_filter_card.dart';
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
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
                padding: const EdgeInsets.only(left: 10, right: 12.0, top: 4),
                child: Icon(FIcons.chevronLeft, size: 20),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.meta.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
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
        FTextField(
          maxLines: 1,
          onChange: (value) {
            // extNotifier.filterByName(value);
          },
          hint: "Search by Name or Tags ...",
          prefixBuilder: (context, style, states) => Padding(
            padding: EdgeInsetsGeometry.only(left: 12, right: 10),
            child: Icon(FIcons.search),
          ),
        ),
      ],
      // snapSheet: <Widget>[
      //   FHeader.nested(
      //     title: const Text('Search'),
      //     titleAlignment: Alignment.centerLeft,
      //     prefixes: [
      //       FHeaderAction.back(
      //         onPress: () {
      //           context.pop();
      //         },
      //       ),
      //     ],
      //   ),
      //   Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         widget.meta.name,
      //         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      //       ),
      //       Consumer(
      //         builder: (context, ref, _) {
      //           final page = ref.watch(
      //             searchPageSingleProviderProvider.select((v) => v.page),
      //           );
      //           return Text('page: ${page.toString()}');
      //         },
      //       ),
      //     ],
      //   ),
      //   const SizedBox(height: 10),

      //   const SizedBox(height: 10),
      // ],
      body: LayoutBuilder(
        builder: (context, cons) {
          final snapshot = ref.watch(
            fetchExtensionLatestProvider.call(widget.meta.packageName, 1),
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
            error: (err, stack) => ErrorDisplay.network(err: err, stack: stack),
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
    final state = ref.watch(searchPageSingleProviderProvider);
    ref.read(
      fetchExtensionSearchLatestProvider.call(
        meta.packageName,
        state.page,
        query: state.query,
      ),
    );
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
                initialText: state.query,
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
                  ref
                      .read(searchPageSingleProviderProvider.notifier)
                      .setQuery(value);
                  refresh(ref);
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
