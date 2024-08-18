import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/views/pages/video_player.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:shimmer/shimmer.dart';

class DetailItemBox extends StatelessWidget {
  const DetailItemBox({
    required this.padding,
    required this.child,
    super.key,
  });
  final Widget child;
  final double padding;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: context.moonTheme?.textInputTheme.colors.textColor
                .withAlpha(20),
            borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: EdgeInsets.all(padding), child: child));
  }
}

class DetailEpButton extends StatelessWidget {
  const DetailEpButton(
      {super.key,
      required this.detail,
      required this.notifier,
      required this.onTap,
      required this.spacing,
      required this.runSpacing});
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
    return ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, selectedValue, child) => Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              children: [
                ...List.generate(detail.episodes![selectedValue].urls.length,
                    (index) {
                  return MoonButton(
                    borderColor: context.moonTheme?.segmentedControlTheme.colors
                        .backgroundColor,
                    backgroundColor: context
                        .moonTheme?.segmentedControlTheme.colors.backgroundColor
                        .withAlpha(150),
                    hoverEffectColor: context.moonTheme?.segmentedControlTheme
                        .colors.backgroundColor,
                    hoverTextColor:
                        context.moonTheme?.tabBarTheme.colors.selectedTextColor,
                    onTap: () => onTap(index),
                    label: Text(
                      detail.episodes![selectedValue].urls[index].name,
                    ),
                  );
                })
              ],
            ));
  }
}

class DesktopDetail extends StatelessWidget {
  const DesktopDetail({
    super.key,
    this.data,
    required this.season,
    required this.desc,
    required this.ep,
    required this.extensionService,
  });
  final List<Widget> desc;
  final List<Widget> ep;
  final List<Widget> season;
  final ExtensionApiV1 extensionService;

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
                maxExt: _maxExtDesktop,
                minExt: _minExtDesktop,
                clampMax: _clampMaxDesktop,
                extensionService: extensionService,
                isLoading: false,
                detail: data)),
        SliverList.list(children: [
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
                    child: Column(children: [
                      DetailItemBox(
                          padding: _gloablDesktopPadding,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: season)),
                      const SizedBox(height: 20),
                      DetailItemBox(
                          padding: _gloablDesktopPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: desc,
                          ))
                    ]),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    flex: 6,
                    child: DetailItemBox(
                        padding: _gloablDesktopPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ep,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ])
      ],
    );
  }
}

class MobileDetail extends StatelessWidget {
  const MobileDetail(
      {super.key,
      this.data,
      this.addition = _default,
      required this.desc,
      required this.ep,
      required this.extensionService});
  final List<Widget> desc;
  final List<Widget> ep;
  final ExtensionApiV1 extensionService;
  final ExtensionDetail? data;
  final Widget Function(Widget child) addition;
  static const double _maxExtMobile = 400;
  static const double _minExtMobile = 80;
  static const double _clampMaxMobile = 100;
  static const _globalMobilePadding = 15.0;
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
                extensionService: extensionService,
                isLoading: false,
                detail: data)),
        SliverList.list(children: [
          Padding(
            padding: const EdgeInsets.all(_globalMobilePadding),
            child: addition(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailItemBox(
                    padding: _globalMobilePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: desc,
                    )),
                const SizedBox(height: 20),
                DetailItemBox(
                    padding: _globalMobilePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ep,
                    )),
                const SizedBox(height: 80),
              ],
            )),
          ),
        ])
      ],
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage(
      {super.key, required this.extensionService, required this.url});
  final ExtensionApiV1 extensionService;
  final String url;

  @override
  createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // Future<ExtensionDetail> _loadData() async {
  //   await Future.delayed(const Duration(seconds: 1000));
  //   return widget.extensionService.detail(widget.url);
  // }

  final ValueNotifier<int> _selectedGroup = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      appBar: const MiruAppBar(
        title: Text("detail"),
      ),
      body: FutureBuilder<ExtensionDetail>(
          future:
              //  _loadData(),
              widget.extensionService.detail(widget.url),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return MediaQuery.removePadding(
                context: context,
                child: PlatformWidget(
                    mobileWidget: MobileDetail(
                      data: data,
                      extensionService: widget.extensionService,
                      ep: [
                        const Text(
                          'Episode',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        DetailEpButton(
                            detail: data,
                            notifier: _selectedGroup,
                            onTap: (value) {
                              context.push('/watch',
                                  extra: WatchParams(
                                      epGroup: data.episodes,
                                      url: data.episodes![_selectedGroup.value]
                                          .urls[value].url,
                                      service: widget.extensionService,
                                      type: widget
                                          .extensionService.extension.type));
                            },
                            spacing: 8,
                            runSpacing: 10)
                      ],
                      desc: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Text(
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          data.desc ?? 'No Description',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    desktopWidget: DesktopDetail(
                      data: data,
                      extensionService: widget.extensionService,
                      ep: [
                        const Text(
                          'Episode',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        DetailEpButton(
                          notifier: _selectedGroup,
                          detail: data,
                          onTap: (value) {
                            context.push('/watch',
                                extra: WatchParams(
                                    epGroup: data.episodes,
                                    url: data.episodes![_selectedGroup.value]
                                        .urls[value].url,
                                    service: widget.extensionService,
                                    type: widget
                                        .extensionService.extension.type));
                          },
                          spacing: 20,
                          runSpacing: 10,
                        ),
                        const SizedBox(height: 8),
                      ],
                      season: [
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Season',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              MoonButton.icon(
                                icon: Text('expand'),
                              )
                            ]),
                        const Divider(),
                        ...List.generate(
                            (data.episodes ?? []).length,
                            (index) => MoonChip(
                                  width: double.infinity,
                                  height: 30,
                                  isActive: false,
                                  activeBackgroundColor: context.moonTheme
                                      ?.tabBarTheme.colors.selectedPillTabColor
                                      .withAlpha(150),
                                  backgroundColor: Colors.transparent,

                                  activeColor: context.moonTheme?.tabBarTheme
                                      .colors.selectedTextColor,
                                  label: Expanded(
                                      child: Text(
                                    data.episodes![index].title,
                                  )),
                                  onTap: () {
                                    _selectedGroup.value = index;
                                  },
                                  // backgroundColor: Theme.of(context).primaryColor,
                                )),
                        const SizedBox(height: 8),
                      ],
                      desc: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Text(
                          data.desc ?? 'No Description',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )),
              );
            }

            return PlatformWidget(
                mobileWidget: MobileDetail(
                  extensionService: widget.extensionService,
                  desc: const [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    LoadingWidget(
                      lineCount: 3,
                      lineheight: 8,
                      lineSeperate: 8,
                      padding: EdgeInsets.all(5),
                    ),
                  ],
                  ep: const [
                    Text(
                      'Episode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    LoadingWidget(
                      lineCount: 3,
                      lineheight: 20,
                      lineSeperate: 15,
                      padding: EdgeInsets.all(5),
                    ),
                  ],
                ),
                desktopWidget: DesktopDetail(
                  ep: const [
                    Text(
                      'Episode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    LoadingWidget(
                      lineCount: 16,
                      lineheight: 20,
                    )
                  ],
                  season: const [
                    Text(
                      'Season',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    LoadingWidget(
                      lineCount: 4,
                      lineheight: 20,
                    )
                  ],
                  desc: const [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    LoadingWidget(
                      lineCount: 8,
                      lineheight: 20,
                    )
                  ],
                  extensionService: widget.extensionService,
                ));
          }),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget(
      {super.key,
      this.header,
      required this.lineCount,
      this.lineSeperate,
      this.lineheight,
      this.padding});
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
                  .moonTheme!.segmentedControlTheme.colors.backgroundColor
                  .withAlpha(50),
              highlightColor: context
                  .moonTheme!.segmentedControlTheme.colors.backgroundColor
                  .withAlpha(100),
              child: Column(
                children: List.generate(
                    lineCount,
                    (index) => Column(
                          children: [
                            SizedBox(
                              height: lineSeperate ?? 20,
                            ),
                            Container(
                              height: lineheight ?? 10,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(90),
                              ),
                            ),
                          ],
                        )),
              ),
            )
          ],
        ));
  }
}

class DetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  double _mapRange(
      double value, double inMin, double inMax, double outMin, double outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }

  const DetailHeaderDelegate(
      {required this.isLoading,
      required this.extensionService,
      required this.minExt,
      required this.maxExt,
      required this.clampMax,
      this.detail});
  final double maxExt;
  final double minExt;
  final double clampMax;
  final bool isLoading;
  final ExtensionDetail? detail;
  final ExtensionApiV1 extensionService;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    debugPrint('shrinkOffset: $shrinkOffset');
    int alpha = _mapRange(shrinkOffset, minExt, maxExt, 0, 255)
        .clamp(0, clampMax)
        .toInt();

    return (Container(
        decoration: BoxDecoration(
            color: Colors.grey,
            image: (isLoading || detail?.cover == null)
                ? null
                : DecorationImage(
                    image: ExtendedNetworkImageProvider(
                      detail?.cover ?? '',
                    ),
                    fit: BoxFit.cover,
                  )),
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      MoonColors.dark.gohan
                          .withAlpha(alpha), // Dark theme gradient colors
                      MoonColors.dark.gohan.withAlpha(128 + (alpha ~/ 2)),
                      MoonColors.dark.gohan,
                    ]
                  : [
                      MoonColors.light.gohan.withAlpha(alpha),
                      MoonColors.light.gohan.withAlpha(128 + (alpha ~/ 2)),
                      MoonColors.light.gohan,
                    ],
            )),
            child: PlatformWidget(
                mobileWidget: LayoutBuilder(
                    builder: (context, constraint) => shrinkOffset > 300
                        ? MaxWidth(
                            maxWidth: constraint.maxWidth - 20.0,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 55,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [
                                          MoonChip(
                                            chipSize: MoonChipSize.sm,
                                            // width: 40,
                                            activeBackgroundColor: context
                                                .moonTheme
                                                ?.segmentedControlTheme
                                                .colors
                                                .backgroundColor,
                                            backgroundColor: Colors.transparent,
                                            textColor: context
                                                .moonTheme
                                                ?.textInputTheme
                                                .colors
                                                .textColor,
                                            label: const Icon(MoonIcons
                                                .sport_featured_24_regular),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            detail?.title ?? 'Title Not Found',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            extensionService.extension.name,
                                            style: const TextStyle(),
                                          )
                                        ]),
                                        Row(children: [
                                          MoonButton(
                                            leading: const Icon(MoonIcons
                                                .media_play_24_regular),
                                            backgroundColor: context
                                                .moonTheme
                                                ?.segmentedControlTheme
                                                .colors
                                                .backgroundColor,
                                            textColor: context
                                                .moonTheme
                                                ?.tabBarTheme
                                                .colors
                                                .selectedTextColor,
                                            onTap: isLoading ? null : () {},
                                            label: const Text('Play'),
                                          ),
                                          const SizedBox(width: 10),
                                          MoonButton(
                                            leading: const Icon(MoonIcons
                                                .sport_featured_24_regular),
                                            backgroundColor: context
                                                .moonTheme
                                                ?.segmentedControlTheme
                                                .colors
                                                .backgroundColor,
                                            textColor: context
                                                .moonTheme
                                                ?.tabBarTheme
                                                .colors
                                                .selectedTextColor,
                                            onTap: isLoading ? null : () {},
                                            label: const Text('Favorite'),
                                          )
                                        ])
                                      ])
                                ]))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                child: (isLoading)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? MoonColors.dark.gohan
                                                    : MoonColors.light.gohan,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
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
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          const LoadingWidget(
                                              padding: EdgeInsets.all(0),
                                              lineCount: 2,
                                              lineheight: 20),
                                        ],
                                      )
                                    : LayoutBuilder(
                                        builder: (context, contraint) => Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(width: 10),
                                                Container(
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
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
                                                    width: constraint.maxWidth -
                                                        135,
                                                    child: DefaultTextStyle(
                                                      style: TextStyle(
                                                        color: context
                                                            .moonTheme
                                                            ?.textInputTheme
                                                            .colors
                                                            .textColor,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            detail?.title ?? '',
                                                            softWrap: true,
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Text(
                                                            extensionService
                                                                .extension.name,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              ],
                                            )),
                              ),
                              const SizedBox(height: 20),
                            ],
                          )),
                desktopWidget: shrinkOffset > 300
                    ? MaxWidth(
                        maxWidth: 1500,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      MoonChip(
                                        chipSize: MoonChipSize.sm,
                                        // width: 40,
                                        activeBackgroundColor: context
                                            .moonTheme
                                            ?.segmentedControlTheme
                                            .colors
                                            .backgroundColor,
                                        backgroundColor: Colors.transparent,
                                        textColor: context.moonTheme
                                            ?.textInputTheme.colors.textColor,
                                        label: const Icon(MoonIcons
                                            .sport_featured_24_regular),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        detail?.title ?? 'Title Not Found',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        extensionService.extension.name,
                                        style: const TextStyle(),
                                      )
                                    ]),
                                    Row(children: [
                                      MoonButton(
                                        leading: const Icon(
                                            MoonIcons.media_play_24_regular),
                                        backgroundColor: context
                                            .moonTheme
                                            ?.segmentedControlTheme
                                            .colors
                                            .backgroundColor,
                                        textColor: context
                                            .moonTheme
                                            ?.tabBarTheme
                                            .colors
                                            .selectedTextColor,
                                        onTap: isLoading ? null : () {},
                                        label: const Text('Play'),
                                      ),
                                      const SizedBox(width: 10),
                                      MoonButton(
                                        leading: const Icon(MoonIcons
                                            .sport_featured_24_regular),
                                        backgroundColor: context
                                            .moonTheme
                                            ?.segmentedControlTheme
                                            .colors
                                            .backgroundColor,
                                        textColor: context
                                            .moonTheme
                                            ?.tabBarTheme
                                            .colors
                                            .selectedTextColor,
                                        onTap: isLoading ? null : () {},
                                        label: const Text('Favorite'),
                                      )
                                    ])
                                  ])
                            ]))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 1500),
                            child: (isLoading)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? MoonColors.dark.gohan
                                                    : MoonColors.light.gohan,
                                            borderRadius:
                                                BorderRadius.circular(10)),
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
                                          child: PlatformWidget(
                                            mobileWidget: Container(
                                              width: 150,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            desktopWidget: Container(
                                              width: 200,
                                              height: 300,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      const LoadingWidget(
                                          padding: EdgeInsets.all(0),
                                          lineCount: 2,
                                          lineheight: 20),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                      const SizedBox(width: 20),
                                      DefaultTextStyle(
                                        style: TextStyle(
                                          color: context.moonTheme
                                              ?.textInputTheme.colors.textColor,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      )))));
  }

  @override
  double get maxExtent => maxExt;

  @override
  double get minExtent => minExt;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
