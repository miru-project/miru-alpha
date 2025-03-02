import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/objectbox.g.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/database_service.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/download/download_utils.dart';

import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/utils/router/router_util.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/views/widgets/dialog/favorite_add_group_dialog.dart';
import 'package:miru_app_new/views/widgets/dialog/favorite_warning_dialog.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:shimmer/shimmer.dart';

class DetailItemBox extends HookWidget {
  const DetailItemBox({
    required this.padding,
    required this.child,
    required this.title,
    this.isMobile = false,
    this.needExpand = true,
    super.key,
  });

  final Widget child;
  final double padding;
  final String title;
  final bool isMobile;
  final minHeight = 300.0;
  final bool needExpand;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(true);

    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height:
            needExpand
                ? null
                : isExpanded.value
                ? null
                : minHeight, // Expand or restrict height
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              color: Colors.black.withValues(alpha: .2),
            ),
          ],
          color: context.moonTheme?.textInputTheme.colors.textColor.withAlpha(
            20,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Expand/Collapse Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "HarmonyOS_Sans",
                    ),
                  ),
                  if (needExpand)
                    MoonButton.icon(
                      onTap: () {
                        isExpanded.value = !isExpanded.value;
                      },
                      iconColor: Colors.grey[500],
                      icon: Text(isExpanded.value ? 'Collapse' : 'Expand'),
                    ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              // Wrap the content with SingleChildScrollView
              if (!isExpanded.value)
                SizedBox(
                  height: minHeight - 100,
                  child: SingleChildScrollView(child: child),
                )
              else
                child,
            ],
          ),
        ),
      ),
    );
  }
}

class DetailEpButton extends HookWidget {
  const DetailEpButton({
    super.key,
    required this.detail,
    required this.notifier,
    required this.onTap,
    required this.spacing,
    required this.runSpacing,
  });
  final ExtensionDetail detail;
  final ValueNotifier<int> notifier;
  final Function(int) onTap;
  final double spacing;
  final double runSpacing;
  @override
  Widget build(BuildContext context) {
    if (detail.episodes == null) {
      return const Text('No Episode');
    }
    return LayoutBuilder(
      builder:
          (context, constraint) => ValueListenableBuilder(
            valueListenable: notifier,
            builder:
                (context, selectedValue, child) =>
                    (detail.episodes!.isEmpty)
                        ? const Text('No Episode')
                        : Wrap(
                          spacing: spacing,
                          runSpacing: runSpacing,
                          children: [
                            ...List.generate(
                              detail.episodes![selectedValue].urls.length,
                              (index) {
                                return MoonButton(
                                  borderColor:
                                      context
                                          .moonTheme
                                          ?.segmentedControlTheme
                                          .colors
                                          .backgroundColor,
                                  backgroundColor: context
                                      .moonTheme
                                      ?.segmentedControlTheme
                                      .colors
                                      .backgroundColor
                                      .withAlpha(150),
                                  hoverEffectColor:
                                      context
                                          .moonTheme
                                          ?.segmentedControlTheme
                                          .colors
                                          .backgroundColor,
                                  hoverTextColor:
                                      context
                                          .moonTheme
                                          ?.segmentedControlTheme
                                          .colors
                                          .textColor,
                                  onTap: () => onTap(index),
                                  label: PlatformWidget(
                                    mobileWidget: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraint.maxWidth - 50,
                                      ),
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        detail
                                            .episodes![selectedValue]
                                            .urls[index]
                                            .name,
                                      ),
                                    ),
                                    desktopWidget: Text(
                                      detail
                                          .episodes![selectedValue]
                                          .urls[index]
                                          .name,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
          ),
    );
  }
}

class DesktopDetail extends StatelessWidget {
  const DesktopDetail({
    super.key,
    this.data,
    this.detailUrl,
    required this.season,
    required this.desc,
    required this.isLoading,
    required this.ep,
    required this.extensionService,
    required this.cast,
  });
  final Widget desc;
  final bool isLoading;
  final Widget ep;
  final Widget season;
  final Widget cast;
  final ExtensionApiV1 extensionService;
  final String? detailUrl;
  final ExtensionDetail? data;

  static const double _maxExtDesktop = 600;
  static const double _minExtDesktop = 60;
  static const double _clampMaxDesktop = 200;
  static const _gloablDesktopPadding = 30.0;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: DetailHeaderDelegate(
            detailUrl: detailUrl,
            maxExt: _maxExtDesktop,
            minExt: _minExtDesktop,
            clampMax: _clampMaxDesktop,
            extensionService: extensionService,
            isLoading: isLoading,
            detail: data,
          ),
        ),
        SliverList.list(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(_gloablDesktopPadding),
              child: MaxWidth(
                maxWidth: 1500,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          DetailItemBox(
                            title: 'Season',
                            padding: _gloablDesktopPadding,
                            child: season,
                          ),
                          const SizedBox(height: 20),
                          DetailItemBox(
                            needExpand: false,
                            title: 'Description',
                            padding: _gloablDesktopPadding,
                            child: desc,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          DetailItemBox(
                            title: 'Episode',
                            padding: _gloablDesktopPadding,
                            child: ep,
                          ),
                          const SizedBox(height: 20),
                          DetailItemBox(
                            padding: _gloablDesktopPadding,
                            title: 'Cast & Rating',
                            child: cast,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MobileDetail extends StatelessWidget {
  const MobileDetail({
    super.key,
    this.data,
    this.addition = _default,
    this.detailUrl,
    required this.desc,
    required this.isLoading,
    required this.ep,
    required this.extensionService,
  });
  final Widget desc;
  final bool isLoading;
  final Widget ep;
  final ExtensionApiV1 extensionService;
  final ExtensionDetail? data;
  final Widget Function(Widget child) addition;
  final String? detailUrl;
  static const double _maxExtMobile = 250;
  static const double _minExtMobile = 50;
  static const double _clampMaxMobile = 100;
  static const _globalMobilePadding = 20.0;
  static Widget _default(Widget child) => child;
  @override
  Widget build(context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: DetailHeaderDelegate(
            maxExt: _maxExtMobile,
            minExt: _minExtMobile,
            clampMax: _clampMaxMobile,
            detailUrl: detailUrl,
            extensionService: extensionService,
            isLoading: false,
            detail: data,
          ),
        ),
        SliverList.list(
          children: [
            Padding(
              padding: const EdgeInsets.all(_globalMobilePadding),
              child: addition(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailItemBox(
                      title: 'Description',
                      isMobile: true,
                      needExpand: false,
                      padding: _globalMobilePadding,
                      child: desc,
                    ),
                    const SizedBox(height: 20),
                    DetailItemBox(
                      title: 'Episode',
                      isMobile: true,
                      padding: _globalMobilePadding,
                      child: ep,
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DetailPage extends StatefulHookConsumerWidget {
  const DetailPage({
    super.key,
    required this.extensionService,
    required this.url,
  });
  final ExtensionApiV1 extensionService;
  final String url;

  @override
  createState() => _DetailPageState();
}

class HistoryNotifier extends StateNotifier<History?> {
  HistoryNotifier(super.state);
  void putHistory(History? history) {
    state = history;
  }
}

class FavoriteNotifier with ChangeNotifier {
  Favorite? favorite;
  void putFavorite(Favorite? favorite) {
    this.favorite = favorite;
    notifyListeners();
  }
}

final _history = StateNotifierProvider<HistoryNotifier, History?>((ref) {
  return HistoryNotifier(null);
});
final _favoriteNotifer = FavoriteNotifier();

class _DetailPageState extends ConsumerState<DetailPage> {
  final ValueNotifier<int> _selectedGroup = ValueNotifier(0);
  static const _trackingTab = ['TMDB', 'AniList'];

  @override
  void initState() {
    final watchedQuery = DatabaseService.historys.query(
      History_.package.equals(widget.extensionService.extension.package),
    );
    watchedQuery.watch().listen((query) {
      final value = query.findFirst();
      ref.read(_history.notifier).putHistory(value);
    });
    final favQuery =
        DatabaseService.fav
            .query(
              Favorite_.package
                  .equals(widget.extensionService.extension.package)
                  .and(Favorite_.url.equals(widget.url)),
            )
            .build();

    _favoriteNotifer.putFavorite(favQuery.findFirst());
    // DatabaseService.historys
    //     .filter()
    //     .packageEqualTo(widget.extensionService.extension.package)
    //     .build()
    //     .watchLazy()
    //     .listen((val) {
    //   DatabaseService.db.historys.where().findFirst().then((value) {
    //     ref.read(_history.notifier).putHistory(value);
    //   });
    // });
    // _favoriteNotifer.putFavorite(DatabaseService.db.favorites
    //     .where()
    //     .packageUrlEqualTo(
    //         widget.extensionService.extension.package, widget.url)
    //     .findFirstSync());
    Future.microtask(
      () => ref
          .read(_history.notifier)
          .putHistory(
            DatabaseService.getHistoryByPackageAndUrl(
              widget.extensionService.extension.package,
              widget.url,
            ),
          ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tancontroller = useTabController(initialLength: _trackingTab.length);
    final snapShot = ref.watch(
      fetchExtensionDetailProvider(widget.extensionService, widget.url),
    );
    final isdropDown = useState(false);
    final epGroup = useState(<ExtensionEpisodeGroup>[]);
    return MiruScaffold(
      mobileHeader: Align(
        alignment: Alignment.centerLeft,
        child: MoonButton(
          label: const Text(
            'Detail',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          onTap: () {
            context.pop();
          },
          leading: const Icon(MoonIcons.controls_chevron_left_16_regular),
        ),
      ),
      sidebar:
          DeviceUtil.isMobileLayout(context)
              ? <Widget>[
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    MoonButton(
                      onTap:
                          ref.watch(_history) == null
                              ? null
                              : () {
                                final snapshot = ref.watch(
                                  fetchExtensionDetailProvider(
                                    widget.extensionService,
                                    widget.url,
                                  ),
                                );
                                snapshot.whenData((data) {
                                  if (data.episodes == null ||
                                      data.episodes!.isEmpty) {
                                    return;
                                  }
                                  context.push(
                                    '/watch',
                                    extra: WatchParams(
                                      name: ref.watch(_history)!.title,
                                      detailImageUrl: data.cover ?? '',
                                      selectedEpisodeIndex:
                                          ref.watch(_history)!.episodeId,
                                      selectedGroupIndex:
                                          ref.watch(_history)!.episodeGroupId,
                                      epGroup: data.episodes,
                                      detailUrl: widget.url,
                                      url:
                                          data
                                              .episodes![ref
                                                  .watch(_history)!
                                                  .episodeGroupId]
                                              .urls[ref
                                                  .watch(_history)!
                                                  .episodeId]
                                              .url,
                                      service: widget.extensionService,
                                      type:
                                          widget
                                              .extensionService
                                              .extension
                                              .type,
                                    ),
                                  );
                                });
                              },
                      label: const Text('play'),
                      leading: const Icon(MoonIcons.media_play_24_regular),
                    ),
                    SizedBox(
                      width: DeviceUtil.getWidth(context) / 3,
                      child: MoonDropdown(
                        dropdownAnchorPosition: MoonDropdownAnchorPosition.top,
                        show: isdropDown.value,
                        content: Column(
                          children: List.generate(
                            epGroup.value.length,
                            (index) => MoonMenuItem(
                              backgroundColor:
                                  index == _selectedGroup.value
                                      ? context
                                          .moonTheme
                                          ?.segmentedControlTheme
                                          .colors
                                          .backgroundColor
                                      : null,
                              label: Text(
                                overflow: TextOverflow.ellipsis,
                                epGroup.value[index].title,
                                style: TextStyle(
                                  color:
                                      index == _selectedGroup.value
                                          ? context
                                              .moonTheme
                                              ?.segmentedControlTheme
                                              .colors
                                              .textColor
                                          : null,
                                ),
                              ),
                              onTap: () {
                                _selectedGroup.value = index;
                                isdropDown.value = false;
                              },
                            ),
                          ),
                        ),
                        child: MoonButton(
                          label: Text(
                            overflow: TextOverflow.ellipsis,
                            epGroup.value.isEmpty
                                ? 'No Season'
                                : epGroup.value[_selectedGroup.value].title,
                          ),
                          onTap: () {
                            isdropDown.value = !isdropDown.value;
                          },
                        ),
                      ),
                    ),
                    MoonButton(
                      label: const Text('WebView'),
                      onTap: () {
                        context.push(
                          '/mobileWebView',
                          extra: WebviewParam(
                            url: widget.url,
                            service: widget.extensionService,
                          ),
                        );
                      },
                      leading: const Icon(MoonIcons.generic_globe_24_regular),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MoonTabBar(
                  tabController: tancontroller,
                  tabs: List.generate(
                    _trackingTab.length,
                    (index) => MoonTab(label: Text(_trackingTab[index])),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: tancontroller,
                    children: [Container(), Container()],
                  ),
                ),
              ]
              : null,
      body: snapShot.when(
        data: (data) {
          epGroup.value = data.episodes ?? [];
          return MediaQuery.removePadding(
            context: context,
            child: PlatformWidget(
              mobileWidget: MobileDetail(
                detailUrl: widget.url,
                isLoading: false,
                data: data,
                extensionService: widget.extensionService,
                ep: DetailEpButton(
                  detail: data,
                  notifier: _selectedGroup,
                  onTap: (value) {
                    context.push(
                      '/watch',
                      extra: WatchParams(
                        detailUrl: widget.url,
                        detailImageUrl: data.cover ?? '',
                        name: data.title,
                        selectedEpisodeIndex: value,
                        selectedGroupIndex: _selectedGroup.value,
                        epGroup: data.episodes,
                        url:
                            data
                                .episodes![_selectedGroup.value]
                                .urls[value]
                                .url,
                        service: widget.extensionService,
                        type: widget.extensionService.extension.type,
                      ),
                    );
                  },
                  spacing: 8,
                  runSpacing: 10,
                ),
                desc: Text(
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  data.desc ?? 'No Description',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              desktopWidget: DesktopDetail(
                isLoading: false,
                detailUrl: widget.url,
                data: data,
                extensionService: widget.extensionService,
                ep: DetailEpButton(
                  notifier: _selectedGroup,
                  detail: data,
                  onTap: (value) {
                    context.push(
                      '/watch',
                      extra: WatchParams(
                        name: data.title,
                        detailImageUrl: data.cover ?? '',
                        selectedEpisodeIndex: value,
                        selectedGroupIndex: _selectedGroup.value,
                        epGroup: data.episodes,
                        detailUrl: widget.url,
                        url:
                            data
                                .episodes![_selectedGroup.value]
                                .urls[value]
                                .url,
                        service: widget.extensionService,
                        type: widget.extensionService.extension.type,
                      ),
                    );
                  },
                  spacing: 20,
                  runSpacing: 10,
                ),
                season: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (data.episodes ?? []).length,
                    (index) => MoonChip(
                      width: double.infinity,
                      height: 30,
                      isActive: false,
                      activeBackgroundColor: context
                          .moonTheme
                          ?.tabBarTheme
                          .colors
                          .selectedPillTabColor
                          .withAlpha(150),
                      backgroundColor: Colors.transparent,

                      // activeColor: context.moonTheme?.tabBarTheme
                      //     .colors.selectedTextColor,
                      label: Expanded(child: Text(data.episodes![index].title)),
                      onTap: () {
                        _selectedGroup.value = index;
                      },
                      // backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                desc: Text(
                  data.desc ?? 'No Description',
                  style: const TextStyle(fontSize: 16),
                ),
                cast: _DetailCast(),
              ),
            ),
          );
        },
        loading:
            () => PlatformWidget(
              mobileWidget: MobileDetail(
                isLoading: true,
                extensionService: widget.extensionService,
                desc: const LoadingWidget(
                  lineCount: 3,
                  lineheight: 8,
                  lineSeperate: 8,
                  padding: EdgeInsets.all(5),
                ),
                ep: const LoadingWidget(
                  lineCount: 3,
                  lineheight: 20,
                  lineSeperate: 15,
                  padding: EdgeInsets.all(5),
                ),
              ),
              desktopWidget: DesktopDetail(
                isLoading: true,
                cast: const LoadingWidget(lineCount: 8, lineheight: 20),
                ep: const LoadingWidget(lineCount: 8, lineheight: 20),
                season: const LoadingWidget(lineCount: 4, lineheight: 20),
                desc: const LoadingWidget(lineCount: 8, lineheight: 20),
                extensionService: widget.extensionService,
              ),
            ),
        error:
            (error, stackTrace) => Center(
              child: Column(
                children: [Text('Error: $error'), Text('Stack: $stackTrace')],
              ),
            ),
      ),
    );
  }
}

class _DetailCast extends HookWidget {
  static const _tabs = ['TMDB', 'AniList'];
  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    return Column(
      children: [
        MoonTabBar(
          isExpanded: true,
          tabController: tabController,
          tabs: List.generate(
            2,
            (index) => MoonTab(
              tabStyle: MoonTabStyle(
                indicatorColor:
                    context
                        .moonTheme
                        ?.segmentedControlTheme
                        .colors
                        .backgroundColor,
                selectedTextColor:
                    context
                        .moonTheme
                        ?.segmentedControlTheme
                        .colors
                        .backgroundColor,
              ),
              label: Text(_tabs[index]),
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: TabBarView(
            controller: tabController,
            children: const [Text('TMDB'), Text('AniList')],
          ),
        ),
      ],
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.header,
    required this.lineCount,
    this.lineSeperate,
    this.lineheight,
    this.padding,
  });
  final Widget? header;
  final int lineCount;
  final double? lineheight;
  final double? lineSeperate;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) header!,
          Shimmer.fromColors(
            baseColor: context
                .moonTheme!
                .segmentedControlTheme
                .colors
                .backgroundColor
                .withAlpha(50),
            highlightColor: context
                .moonTheme!
                .segmentedControlTheme
                .colors
                .backgroundColor
                .withAlpha(100),
            child: Column(
              children: List.generate(
                lineCount,
                (index) => Column(
                  children: [
                    SizedBox(height: lineSeperate ?? 20),
                    Container(
                      height: lineheight ?? 10,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(90),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSideWidgetMobile extends ConsumerWidget {
  const _DetailSideWidgetMobile({
    required this.constraint,
    this.detail,
    this.detailUrl,
    required this.extensionService,
  });
  final ExtensionDetail? detail;
  final String? detailUrl;
  final ExtensionApiV1 extensionService;
  final BoxConstraints constraint;
  @override
  Widget build(BuildContext context, ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 30),
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExtendedImage.network(
            detail?.cover ?? '',
            width: 100,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: constraint.maxWidth - 145,
          child: DefaultTextStyle(
            style: TextStyle(
              color: context.moonTheme?.textInputTheme.colors.textColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail?.title ?? '',
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "HarmonyOS_Sans",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      ExtendedImage.network(
                        width: 20,
                        height: 20,
                        extensionService.extension.icon ?? '',
                        loadStateChanged: (state) {
                          if (state.extendedImageLoadState ==
                              LoadState.failed) {
                            return const Icon(Icons.error);
                          }
                          return null;
                        },
                        cache: true,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        extensionService.extension.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    MoonButton(
                      borderColor:
                          context
                              .moonTheme
                              ?.segmentedControlTheme
                              .colors
                              .backgroundColor,
                      textColor:
                          context
                              .moonTheme
                              ?.segmentedControlTheme
                              .colors
                              .textColor,
                      backgroundColor:
                          context
                              .moonTheme
                              ?.segmentedControlTheme
                              .colors
                              .backgroundColor,
                      label: const Text('Play'),
                      onTap:
                          ref.watch(_history) == null
                              ? null
                              : () {
                                if (detail == null || detailUrl == null) {
                                  return;
                                }
                                context.push(
                                  '/watch',
                                  extra: WatchParams(
                                    name: ref.watch(_history)!.title,
                                    detailImageUrl: detail!.cover ?? '',
                                    selectedEpisodeIndex:
                                        ref.watch(_history)!.episodeId,
                                    selectedGroupIndex:
                                        ref.watch(_history)!.episodeGroupId,
                                    epGroup: detail!.episodes,
                                    detailUrl: detailUrl!,
                                    url:
                                        detail!
                                            .episodes![ref
                                                .watch(_history)!
                                                .episodeGroupId]
                                            .urls[ref
                                                .watch(_history)!
                                                .episodeId]
                                            .url,
                                    service: extensionService,
                                    type: extensionService.extension.type,
                                  ),
                                );
                              },
                    ),
                    const SizedBox(width: 10),
                    ListenableBuilder(
                      listenable: _favoriteNotifer,
                      builder:
                          (context, _) => MoonChip(
                            isActive: _favoriteNotifer.favorite != null,
                            activeColor:
                                context
                                    .moonTheme
                                    ?.segmentedControlTheme
                                    .colors
                                    .textColor,
                            borderColor:
                                context
                                    .moonTheme
                                    ?.segmentedControlTheme
                                    .colors
                                    .backgroundColor,
                            textColor:
                                context
                                    .moonTheme
                                    ?.textInputTheme
                                    .colors
                                    .textColor,
                            backgroundColor:
                                context
                                    .moonTheme
                                    ?.textInputTheme
                                    .colors
                                    .backgroundColor,
                            label: Text(
                              _favoriteNotifer.favorite != null
                                  ? 'Favorited'
                                  : 'Favorite',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "HarmonyOS_Sans",
                              ),
                            ),
                            leading: const Icon(
                              MoonIcons.generic_star_24_regular,
                            ),
                            onTap: () {
                              if (detail == null || detailUrl == null) {
                                return;
                              }
                              showMoonModal(
                                context: context,
                                builder:
                                    (context) => _FavoriteDialog(
                                      extensionService: extensionService,
                                      detail: detail!,
                                      detailUrl: detailUrl!,
                                    ),
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FavoriteDialog extends StatefulWidget {
  const _FavoriteDialog({
    required this.extensionService,
    required this.detailUrl,
    required this.detail,
  });
  final String detailUrl;
  final ExtensionDetail detail;
  final ExtensionApiV1 extensionService;

  @override
  createState() => _FavoriteDialogState();
}

class _FavoriteDialogState extends State<_FavoriteDialog> {
  final ValueNotifier<List<FavoriateGroup>> group = ValueNotifier([]);
  final ValueNotifier<List<int>> selected = ValueNotifier([]);
  final ValueNotifier<List<int>> selectedToDelete = ValueNotifier([]);
  final ValueNotifier<List<int>> setLongPress = ValueNotifier([]);
  final ValueNotifier<List<int>> setSelected = ValueNotifier([]);
  final List<int> initSelected = [];
  @override
  void initState() {
    group.value = DatabaseService.favGroup.getAll();
    DatabaseService.favGroup.query().watch().listen((query) {
      group.value = query.find();
    });
    // DatabaseService.db.favoriateGroups.where().watchLazy().listen((_) {
    //   group.value = DatabaseService.db.favoriateGroups.where().findAllSync();
    //   // debugger();
    // });
    if (_favoriteNotifer.favorite != null) {
      final result = DatabaseService.getFavoriteGroupsById(
        _favoriteNotifer.favorite!.id,
      );
      final nameList = group.value.map((e) => e.name).toList();
      for (final item in result) {
        initSelected.add(nameList.indexOf(item.name));
      }
      selected.value = initSelected;
      debugPrint(initSelected.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final factor = DeviceUtil.isMobileLayout(context) ? 0.8 : .5;
    final width = DeviceUtil.getWidth(context);
    final height = DeviceUtil.getHeight(context);

    return MoonModal(
      decoration: BoxDecoration(
        color: MoonColors.dark.goku,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color:
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? MoonColors.light.goku.withValues(alpha: .2)
                    : MoonColors.dark.goku.withValues(alpha: .2),
          ),
        ],
      ),
      child: ValueListenableBuilder(
        valueListenable: group,
        builder:
            (context, value, _) => SizedBox(
              width: width * factor,
              height: height * factor,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "HarmonyOS_Sans",
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Favorite ?', style: TextStyle(fontSize: 25)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Selected Group',
                            style: TextStyle(fontSize: 15),
                          ),
                          ValueListenableBuilder(
                            valueListenable: selectedToDelete,
                            builder:
                                (context, delete, _) =>
                                    delete.isEmpty
                                        ? Text(
                                          DeviceUtil.device(
                                            mobile:
                                                'Long Press To Delete Group',
                                            desktop:
                                                'Right Click To Delete Group',
                                            context: context,
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.normal,
                                            fontSize: 10,
                                          ),
                                        )
                                        : MoonButton(
                                          label: const Icon(
                                            MoonIcons.generic_delete_24_regular,
                                          ),
                                          onTap: () {
                                            showMoonModal(
                                              context: context,
                                              builder:
                                                  (
                                                    context,
                                                  ) => FavoriteWarningDialog(
                                                    setLongPress: setLongPress,
                                                    setSelected: setSelected,
                                                    selectedToDelete:
                                                        selectedToDelete,
                                                    selected: selected,
                                                    group: group,
                                                  ),
                                            );
                                          },
                                        ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: CatergoryGroupChip(
                            setLongPress: setLongPress,
                            setSelected: setSelected,
                            onLongPress: (p0) {
                              selectedToDelete.value = p0;
                            },
                            minSelected: 0,
                            trailing: MoonButton(
                              leading: const Icon(
                                MoonIcons.controls_plus_24_regular,
                              ),
                              width: width * factor - 100,
                              backgroundColor:
                                  context
                                      .moonTheme
                                      ?.textInputTheme
                                      .colors
                                      .backgroundColor,
                              onTap: () {
                                showMoonModal(
                                  context: context,
                                  builder:
                                      (context) => FavoriteAddGroupDialog(
                                        onComplete: (p0) {
                                          DatabaseService.putFavoriteGroup(p0);
                                        },
                                      ),
                                );
                              },
                              label: const Text(
                                'Add Group',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "HarmonyOS_Sans",
                                ),
                              ),
                            ),
                            items: group.value.map((val) => val.name).toList(),
                            onpress: (val) {
                              selected.value = val;
                            },
                            initSelected: initSelected,
                          ),
                        ),
                      ),
                      (Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MoonButton(
                            buttonSize: MoonButtonSize.lg,
                            label: const Text('Cancel'),
                            onTap: () {
                              context.pop();
                            },
                          ),
                          Row(
                            children: [
                              MoonButton(
                                buttonSize: MoonButtonSize.lg,
                                label: const Text('Delete'),
                                onTap:
                                    _favoriteNotifer.favorite == null
                                        ? null
                                        : () {
                                          //remove from favorite
                                          DatabaseService.deleteFavorite(
                                            widget.detailUrl,
                                            widget
                                                .extensionService
                                                .extension
                                                .package,
                                          );
                                          _favoriteNotifer.putFavorite(null);
                                          context.pop();
                                        },
                              ),
                              MoonButton(
                                buttonSize: MoonButtonSize.lg,
                                label: Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color:
                                        context
                                            .moonTheme
                                            ?.segmentedControlTheme
                                            .colors
                                            .backgroundColor,
                                  ),
                                ),
                                onTap: () {
                                  final fav = DatabaseService.putFavorite(
                                    widget.detailUrl,
                                    widget.detail,
                                    widget.extensionService.extension.package,
                                    widget.extensionService.extension.type,
                                  );
                                  _favoriteNotifer.putFavorite(fav);

                                  final result =
                                      group.value.map((e) {
                                        final List<Favorite> item = e.favorite
                                            .toList(growable: true);
                                        // remove every fav id from the group
                                        item.removeWhere(
                                          (element) => element.id == fav.id,
                                        );
                                        // add the fav id to the group if selected
                                        if (selected.value.contains(
                                          group.value.indexOf(e),
                                        )) {
                                          item.add(fav);
                                        }
                                        e.favorite.addAll(item);
                                        return e;
                                      }).toList();

                                  DatabaseService.putFavoriteByIndex(result);

                                  context.pop();
                                },
                              ),
                            ],
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class DetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  double _mapRange(
    double value,
    double inMin,
    double inMax,
    double outMin,
    double outMax,
  ) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }

  const DetailHeaderDelegate({
    required this.isLoading,
    required this.extensionService,
    required this.minExt,
    required this.maxExt,
    required this.clampMax,
    this.detailUrl,
    this.detail,
  });
  final double maxExt;
  final double minExt;
  final double clampMax;
  final bool isLoading;
  final ExtensionDetail? detail;
  final ExtensionApiV1 extensionService;
  final String? detailUrl;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    debugPrint('shrinkOffset: $shrinkOffset');
    int alpha =
        _mapRange(
          shrinkOffset,
          minExt,
          maxExt,
          0,
          255,
        ).clamp(0, clampMax).toInt();

    return (Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        image:
            (isLoading || detail?.cover == null)
                ? null
                : DecorationImage(
                  image: ExtendedNetworkImageProvider(detail?.cover ?? ''),
                  fit: BoxFit.cover,
                ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                Theme.of(context).brightness == Brightness.dark
                    ? [
                      MoonColors.dark.gohan.withAlpha(
                        alpha,
                      ), // Dark theme gradient colors
                      MoonColors.dark.gohan.withAlpha(128 + (alpha ~/ 2)),
                      MoonColors.dark.gohan,
                    ]
                    : [
                      MoonColors.light.gohan.withAlpha(alpha),
                      MoonColors.light.gohan.withAlpha(128 + (alpha ~/ 2)),
                      MoonColors.light.gohan,
                    ],
          ),
        ),
        child: PlatformWidget(
          mobileWidget: LayoutBuilder(
            builder: (context, constraint) {
              if (shrinkOffset > 60) {
                return MaxWidth(
                  maxWidth: constraint.maxWidth - 20.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              MoonChip(
                                chipSize: MoonChipSize.sm,
                                activeBackgroundColor:
                                    context
                                        .moonTheme
                                        ?.segmentedControlTheme
                                        .colors
                                        .backgroundColor,
                                backgroundColor: Colors.transparent,
                                textColor:
                                    context
                                        .moonTheme
                                        ?.textInputTheme
                                        .colors
                                        .textColor,
                                label: const Icon(
                                  MoonIcons.sport_featured_24_regular,
                                ),
                              ),
                              SizedBox(
                                width: constraint.maxWidth * .6,
                                child: Text(
                                  detail?.title ?? 'Title Not Found',
                                  style: const TextStyle(
                                    fontFamily: "HarmonyOS_Sans",
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                extensionService.extension.name,
                                style: const TextStyle(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child:
                        (isLoading)
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? MoonColors.dark.gohan
                                            : MoonColors.light.gohan,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Shimmer.fromColors(
                                    baseColor: context
                                        .moonTheme!
                                        .segmentedControlTheme
                                        .colors
                                        .backgroundColor
                                        .withAlpha(50),
                                    highlightColor: context
                                        .moonTheme!
                                        .segmentedControlTheme
                                        .colors
                                        .backgroundColor
                                        .withAlpha(100),
                                    child: Container(
                                      width: 150,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const LoadingWidget(
                                  padding: EdgeInsets.all(0),
                                  lineCount: 2,
                                  lineheight: 20,
                                ),
                              ],
                            )
                            : LayoutBuilder(
                              builder:
                                  (context, contraint) =>
                                      _DetailSideWidgetMobile(
                                        constraint: constraint,
                                        detail: detail,
                                        detailUrl: detailUrl,
                                        extensionService: extensionService,
                                      ),
                            ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
          desktopWidget:
              shrinkOffset > 250
                  ? MaxWidth(
                    maxWidth: 1500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        LayoutBuilder(
                          builder:
                              (context, constraint) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (detail != null)
                                        DownloadButton(
                                          extensionService: extensionService,
                                          // detailUrl: detailUrl,
                                          detail: detail!,
                                          isIcon: true,
                                        ),
                                      const SizedBox(width: 10),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: constraint.maxWidth * .5,
                                        ),
                                        child: Text(
                                          overflow: TextOverflow.ellipsis,
                                          detail?.title ?? 'Title Not Found',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        extensionService.extension.name,
                                        style: const TextStyle(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      MoonButton(
                                        leading: const Icon(
                                          MoonIcons.media_play_24_regular,
                                        ),
                                        backgroundColor:
                                            context
                                                .moonTheme
                                                ?.segmentedControlTheme
                                                .colors
                                                .backgroundColor,
                                        textColor:
                                            context
                                                .moonTheme
                                                ?.segmentedControlTheme
                                                .colors
                                                .textColor,
                                        onTap: isLoading ? null : () {},
                                        label: const Text('Play'),
                                      ),
                                      const SizedBox(width: 10),
                                      _FavButton(
                                        extensionService: extensionService,
                                        detailUrl: detailUrl,
                                        detail: detail,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 1500),
                        child:
                            (isLoading)
                                ? _DesktopLoadingWidgetExtended()
                                : _DesktopWidgetExtended(
                                  extensionService: extensionService,
                                  detailUrl: detailUrl,
                                  detail: detail,
                                ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
        ),
      ),
    ));
  }

  @override
  double get maxExtent => maxExt;

  @override
  double get minExtent => minExt;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.isIcon,
    // this.detailUrl,
    required this.detail,
    required this.extensionService,
  });

  final bool isIcon;
  // final String? detailUrl;
  final ExtensionDetail detail;
  final ExtensionApiV1 extensionService;
  // final String url;
  @override
  Widget build(BuildContext context) {
    if (isIcon) {
      return MoonButton.icon(
        icon: Icon(MoonIcons.generic_download_24_regular),
        onTap: () => onTap(context),
      );
    }
    return MoonButton(
      label: const Text('Download'),
      onTap: () => onTap(context),
      leading: Icon(MoonIcons.generic_download_24_regular),
    );
  }

  void onTap(context) {
    showMoonModal(
      context: context,
      builder: (context) => _DownloadDialog(detail, extensionService),
    );
  }
}

class _DownloadDialog extends StatefulHookWidget {
  const _DownloadDialog(this.detail, this.extensionService);
  final ExtensionDetail detail;
  final ExtensionApiV1 extensionService;
  @override
  createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog>
    with TickerProviderStateMixin {
  late final TabController tabController;
  late final ValueNotifier<int> isSelected;

  @override
  void initState() {
    isSelected = ValueNotifier(0);
    tabController = TabController(
      length: widget.detail.episodes?.length ?? 0,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    isSelected.dispose();
    tabController.dispose();
    super.dispose();
  }

  Widget tabBar() {
    return MoonTabBar(
      onTabChanged: (value) {
        tabController.animateTo(value);
        isSelected.value = value;
      },
      tabs: List.generate(
        widget.detail.episodes?.length ?? 0,
        (index) => MoonTab(label: Text(widget.detail.episodes![index].title)),
      ),
    );
  }

  Widget tabView(List<ExtensionEpisodeGroup> epGroup, BuildContext context) {
    final service = widget.extensionService;
    return ValueListenableBuilder(
      valueListenable: isSelected,
      builder:
          (context, value, child) => TabBarView(
            controller: tabController,
            children: (List.generate(
              epGroup.length,
              (index) => ListView.builder(
                itemBuilder: (context, index) {
                  return MoonMenuItem(
                    // onTap: () {
                    //   final testM3u8 =
                    //       "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8";
                    //   DownloadUtils.addTask(
                    //     VideoDownlodTasks(
                    //       episodeName: epGroup[value].urls[index].name,
                    //       episodeGroupName: epGroup[value].title,
                    //       videoName: widget.detail.title,
                    //       watchType: ExtensionWatchBangumiType.hls,
                    //       videoUrl: testM3u8,
                    //       packageName: service.className,
                    //     ),
                    //     context,
                    //   );
                    // },
                    onTap: () async {
                      final videoWatch =
                          await widget.extensionService.watch(
                                epGroup[value].urls[index].url,
                              )
                              as ExtensionBangumiWatch?;

                      if (videoWatch == null) return;
                      DownloadUtils.addTask(
                        VideoDownlodTasks(
                          episodeName: epGroup[value].urls[index].name,
                          episodeGroupName: epGroup[value].title,
                          videoName: widget.detail.title,
                          watchType: videoWatch.type,
                          videoUrl: videoWatch.url,
                          packageName: service.extension.package,
                        ),
                        context,
                      );
                    },
                    label: Text(epGroup[value].urls[index].name),
                  );
                },
                itemCount: epGroup[value].urls.length,
              ),
            )),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final epGroup = widget.detail.episodes;
    return MoonModal(
      decoration: BoxDecoration(
        color: MoonColors.dark.goku,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color:
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? MoonColors.light.goku.withValues(alpha: .2)
                    : MoonColors.dark.goku.withValues(alpha: .2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder:
              (context, constraints) => SizedBox(
                width: constraints.maxWidth * .4,
                height: constraints.maxHeight * .5,
                child: MoonModal(
                  child:
                      (epGroup == null)
                          ? Center(child: Text("No Episodes found"))
                          : Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                tabBar(),
                                const SizedBox(height: 10),
                                Expanded(child: tabView(epGroup, context)),
                              ],
                            ),
                          ),
                ),
              ),
        ),
      ),
    );
  }
}

class _DesktopWidgetExtended extends StatelessWidget {
  const _DesktopWidgetExtended({
    required this.extensionService,
    this.detailUrl,
    this.detail,
  });
  final String? detailUrl;
  final ExtensionDetail? detail;
  final ExtensionApiV1 extensionService;
  void onTap() async {
    final url = extensionService.extension.webSite + detailUrl!;
    final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          windowHeight: 1280,
          windowWidth: 720,
          title: "ExampleTestWindow",
          titleBarTopPadding: Platform.isMacOS ? 20 : 0,
          // userDataFolderWindows: await _getWebViewPath(),
        ),
      )
      ..launch(url);
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final cookies = await webview.getAllCookies();

        if (cookies.isEmpty) {
          debugPrint('⚠️ no cookies found');
        }

        final cookieString = cookies
            .map((e) => '${e.name}=${e.value}')
            .toList()
            .join(';');
        extensionService.setcookie(cookieString);
      } catch (e, stack) {
        debugPrint('getAllCookies error: $e');
        debugPrintStack(stackTrace: stack);
      }
    });
    webview.onClose.whenComplete(() async {
      debugPrint("on close");
      timer.cancel();

      // timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraint) => Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: PlatformWidget(
                  mobileWidget: ExtendedImage.network(
                    detail?.cover ?? '',
                    width: 150,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  desktopWidget: ExtendedImage.network(
                    detail?.cover ?? '',
                    width: 200,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 40),
              DefaultTextStyle(
                style: TextStyle(
                  color: context.moonTheme?.textInputTheme.colors.textColor,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraint.maxWidth * .8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail?.title ?? '',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        extensionService.extension.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 60),
                      Row(
                        children: [
                          _FavButton(
                            extensionService: extensionService,
                            detailUrl: detailUrl,
                            detail: detail,
                          ),
                          const SizedBox(width: 10),
                          MoonButton(
                            leading: const Icon(
                              MoonIcons.generic_globe_24_regular,
                            ),
                            label: const Text('Webview'),
                            onTap: onTap,
                          ),
                          const SizedBox(width: 10),
                          if (detail != null)
                            DownloadButton(
                              extensionService: extensionService,

                              detail: detail!,
                              isIcon: false,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _DesktopLoadingWidgetExtended extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 20),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? MoonColors.dark.gohan
                    : MoonColors.light.gohan,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Shimmer.fromColors(
            baseColor: context
                .moonTheme!
                .segmentedControlTheme
                .colors
                .backgroundColor
                .withAlpha(50),
            highlightColor: context
                .moonTheme!
                .segmentedControlTheme
                .colors
                .backgroundColor
                .withAlpha(100),
            child: Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        const LoadingWidget(
          padding: EdgeInsets.all(0),
          lineCount: 2,
          lineheight: 20,
        ),
      ],
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({
    required this.extensionService,
    this.detailUrl,
    this.detail,
  });
  final String? detailUrl;
  final ExtensionDetail? detail;
  final ExtensionApiV1 extensionService;
  @override
  Widget build(BuildContext context) {
    return MoonChip(
      isActive: _favoriteNotifer.favorite != null,
      activeColor: context.moonTheme?.segmentedControlTheme.colors.textColor,
      borderColor:
          context.moonTheme?.segmentedControlTheme.colors.backgroundColor,
      textColor: context.moonTheme?.textInputTheme.colors.textColor,
      backgroundColor: context.moonTheme?.textInputTheme.colors.backgroundColor,
      label: Text(
        _favoriteNotifer.favorite != null ? 'Favorited' : 'Favorite',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "HarmonyOS_Sans",
        ),
      ),
      leading: const Icon(MoonIcons.generic_star_24_regular),
      onTap: () {
        if (detail == null || detailUrl == null) {
          return;
        }
        showMoonModal(
          context: context,
          builder:
              (context) => _FavoriteDialog(
                extensionService: extensionService,
                detail: detail!,
                detailUrl: detailUrl!,
              ),
        );
      },
    );
  }
}
