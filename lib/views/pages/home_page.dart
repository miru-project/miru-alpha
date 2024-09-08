import 'dart:developer';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:isar/isar.dart';
import 'package:miru_app_new/utils/database_service.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:go_router/go_router.dart';

class HomePageCarousel extends StatelessWidget {
  const HomePageCarousel({super.key, required this.item});
  final History item;

  convertTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final extensionIsExist = ExtensionUtils.runtimes.containsKey(item.package);
    return GestureDetector(
        onTap: () {
          if (extensionIsExist) {
            context.push('/search/detail',
                extra: DetailParam(
                    service: ExtensionUtils.runtimes[item.package]!,
                    url: item.url));
          }
        },
        child: Container(
            decoration: BoxDecoration(
                color: context.moonTheme?.textInputTheme.colors.textColor
                    .withAlpha(20),
                borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              ExtendedImage.network(
                shape: BoxShape.rectangle,
                fit: BoxFit.fitHeight,
                item.cover ?? '',
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20), right: Radius.circular(10)),
              ),
              const SizedBox(width: 15),
              DefaultTextStyle(
                  style: TextStyle(
                    color: context.moonTheme?.chipTheme.colors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  child: SizedBox(
                      width: DeviceUtil.device(
                          mobile: DeviceUtil.getWidth(context) - 200,
                          desktop: DeviceUtil.getWidth(context) * .25,
                          context: context),
                      child: Flex(
                        direction: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Expanded(
                              flex: 3,
                              child: Text(
                                item.title,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontSize: 20, fontFamily: "HarmonyOS_Sans"),
                              )),
                          const Expanded(flex: 1, child: SizedBox(height: 10)),
                          Text(item.episodeTitle,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 17, fontFamily: "HarmonyOS_Sans")),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 20,
                            child: Row(
                              children: [
                                ExtendedImage.network(
                                  loadStateChanged: (state) {
                                    if (state.extendedImageLoadState ==
                                        LoadState.failed) {
                                      return const Icon(Icons.error);
                                    }
                                    return null;
                                  },
                                  cache: true,
                                  extensionIsExist
                                      ? ExtensionUtils.runtimes[item.package]!
                                              .extension.icon ??
                                          ''
                                      : '',
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  extensionIsExist
                                      ? ExtensionUtils.runtimes[item.package]!
                                          .extension.name
                                      : 'Unknown',
                                  style: const TextStyle(
                                      fontFamily: "HarmonyOS_Sans"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                              flex: 1,
                              child: Text(
                                convertTime(item.date),
                              )),
                        ],
                      )))
            ])));
  }
}

class HistoryPage extends StatefulHookWidget {
  const HistoryPage({super.key, required, required this.historyNotifier});
  final HistoryChangeNotifier historyNotifier;
  @override
  createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  // late List<History> _history;
  @override
  get wantKeepAlive => true;
  convertTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void initState() {
    final history = DatabaseService.db.historys
        .where()
        .sortByDateDesc()
        // .limit(40)
        .findAllSync();
    widget.historyNotifier.update(history);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectedDot = useState(0);
    final width = DeviceUtil.getWidth(context);
    return ListenableBuilder(
        listenable: widget.historyNotifier,
        builder: (context, child) => CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 10,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: DeviceUtil.device(
                        mobile: 200, desktop: 300, context: context),
                    child: OverflowBox(
                      maxWidth: DeviceUtil.device(
                          mobile: width, desktop: width * .9, context: context),
                      child: MoonCarousel(
                        loop: true,
                        autoPlay: true,
                        autoPlayDelay: const Duration(seconds: 5),
                        gap: 12,
                        itemCount: 10,
                        itemExtent: DeviceUtil.device(
                            mobile: width - 32,
                            desktop: width * .4,
                            context: context),
                        onIndexChanged: (int index) =>
                            selectedDot.value = index,
                        itemBuilder:
                            (BuildContext context, int itemIndex, int _) {
                          if (widget.historyNotifier.history.length <=
                              itemIndex) {
                            return const Center(
                              child: Text(
                                'No history',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontFamily: "HarmonyOS_Sans"),
                              ),
                            );
                          }
                          final item =
                              widget.historyNotifier.history[itemIndex];

                          return HomePageCarousel(item: item);
                        },
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    sliver: SliverToBoxAdapter(
                      child: MoonDotIndicator(
                        selectedDot: selectedDot.value,
                        dotCount: 10,
                      ),
                    )),
                SliverPadding(
                  padding: const EdgeInsets.all(15.0),
                  sliver: SliverGrid(
                    gridDelegate: DeviceUtil.device(
                        mobile: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: DeviceUtil.getWidth(context) ~/ 110,
                          childAspectRatio: 0.6,
                        ),
                        desktop: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              DeviceUtil.getWidth(context) * .875 ~/ 180,
                          childAspectRatio: 0.65,
                        ),
                        context: context),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = widget.historyNotifier.history[index];
                        return MiruGridTile(
                          title: item.title,
                          subtitle: item.episodeTitle,
                          imageUrl: item.cover,
                          onTap: () {
                            final extensionIsExist = ExtensionUtils.runtimes
                                .containsKey(item.package);
                            if (extensionIsExist) {
                              context.push('/search/detail',
                                  extra: DetailParam(
                                      service: ExtensionUtils
                                          .runtimes[item.package]!,
                                      url: item.url));
                            }
                          },
                        );
                      },
                      childCount: widget.historyNotifier.history.length,
                    ),
                  ),
                ),
              ],
            ));
  }
}

class HistoryChangeNotifier with ChangeNotifier {
  List<History> history = [];

  void update(List<History> updateValue) {
    history = updateValue;
    notifyListeners();
  }
}

class FavoritePage extends StatefulHookWidget {
  const FavoritePage({super.key, required this.selected});
  final ValueNotifier<List<int>> selected;
  @override
  State<StatefulWidget> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<List<FavoriateGroup>> _favGroup = ValueNotifier([]);
  @override
  get wantKeepAlive => true;
  final ValueNotifier<List<Favorite>> _fav = ValueNotifier([]);
  @override
  void initState() {
    _fav.value = DatabaseService.getAllFavorite();
    _favGroup.value = DatabaseService.getAllFavoriteGroup();
    //listen to favorite change  and filter by group if changes
    DatabaseService.db.favorites.watchLazy().listen((event) {
      if (widget.selected.value.isEmpty) {
        _fav.value = DatabaseService.getAllFavorite();
        return;
      }
      _fav.value = filterFavoriteByGroup(DatabaseService.getAllFavorite());
    });
    //listen to group change
    DatabaseService.db.favoriateGroups.watchLazy().listen((event) {
      _favGroup.value =
          DatabaseService.db.favoriateGroups.where().findAllSync();
    });
    // listen to selected group change
    widget.selected.addListener(() {
      if (widget.selected.value.isEmpty) {
        _fav.value = DatabaseService.getAllFavorite();
        return;
      }
      debugPrint('selected: ${widget.selected.value}');
      _fav.value = filterFavoriteByGroup(_fav.value);
    });
    super.initState();
  }

  List<Favorite> filterFavoriteByGroup(List<Favorite> fav) {
    final List<FavoriateGroup> selectedFavGroup =
        widget.selected.value.map((e) => _favGroup.value[e]).toList();
    final Set<int> favId = {};
    for (final group in selectedFavGroup) {
      favId.addAll(group.items);
    }

    final List<Favorite?> result = List.from(
        DatabaseService.db.favorites.getAllSync(favId.toList()),
        growable: true);
    // result.removeWhere((element) => element == null);
    return result.whereType<Favorite>().toList();
  }

  @override
  void dispose() {
    debugger();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder(
        valueListenable: _fav,
        builder: (context, fav, _) => MiruGridView(
            desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 220,
              childAspectRatio: 0.65,
            ),
            mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DeviceUtil.getWidth(context) ~/ 150,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              return MiruGridTile(
                title: fav[index].title,
                subtitle: fav[index].package,
                imageUrl: fav[index].cover,
                onTap: () {
                  final extensionIsExist =
                      ExtensionUtils.runtimes.containsKey(fav[index].package);
                  if (extensionIsExist) {
                    context.push('/search/detail',
                        extra: DetailParam(
                            service:
                                ExtensionUtils.runtimes[fav[index].package]!,
                            url: fav[index].url));
                  }
                },
              );
            },
            itemCount: fav.length));
  }
}

class FavoriteTab extends StatefulHookWidget {
  const FavoriteTab(
      {super.key,
      required this.isLongPress,
      required this.favGroup,
      required this.setSelected,
      required this.selected,
      required this.setLongPress});
  final ValueNotifier<bool> isLongPress;
  final ValueNotifier<List<int>> setLongPress;
  final ValueNotifier<List<FavoriateGroup>> favGroup;
  final ValueNotifier<List<int>> setSelected;
  final ValueNotifier<List<int>> selected;
  @override
  State<StatefulWidget> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  @override
  void initState() {
    widget.favGroup.value =
        DatabaseService.db.favoriateGroups.where().findAllSync();
    DatabaseService.db.favoriateGroups.watchLazy().listen((event) {
      widget.favGroup.value =
          DatabaseService.db.favoriateGroups.where().findAllSync();
    });
    super.initState();
  }

  String text = '';
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final errorText = useState<String?>(null);
    final isShowAddPopUp = useState(false);
    textController.addListener(() {
      text = textController.text;
      if (text.isEmpty) {
        errorText.value = 'Name is empty';
        return;
      }
      if (widget.favGroup.value.any((element) => element.name == text)) {
        errorText.value = 'Same name exists';
        return;
      }
      errorText.value = null;
    });
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: (ValueListenableBuilder(
            valueListenable: widget.favGroup,
            builder: (context, favGroupValue, _) => ValueListenableBuilder(
                valueListenable: widget.selected,
                builder: (context, val, _) => Wrap(
                      spacing: 5,
                      runSpacing: 10,
                      children: [
                        ...List.generate(
                            favGroupValue.length,
                            (index) => MoonPopover(
                                onTapOutside: () {
                                  widget.setLongPress.value = [];
                                },
                                maxWidth: 170,
                                decoration: BoxDecoration(
                                    color: context.moonTheme?.chipTheme.colors
                                        .backgroundColor,
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                popoverPosition: MoonPopoverPosition.bottom,
                                content: Column(
                                  children: [
                                    Text('Edit',
                                        style: TextStyle(
                                            color: context.moonTheme?.chipTheme
                                                .colors.textColor,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "HarmonyOS_Sans")),
                                    const SizedBox(height: 20),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: MoonFormTextInput(
                                          errorText: errorText.value,
                                          inactiveBorderColor:
                                              Colors.transparent,
                                          hintText: 'Group Name',
                                          trailing: MoonButton.icon(
                                              onTap: () {
                                                textController.clear();
                                              },
                                              buttonSize: MoonButtonSize.sm,
                                              icon: const Icon(MoonIcons
                                                  .controls_close_24_regular)),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "HarmonyOS_Sans"),
                                          // textInputSize:
                                          //     MoonTextInputSize.sm,
                                          controller: textController,
                                        )),
                                    // const SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MoonButton.icon(
                                            onTap: () {
                                              // delete group
                                              DatabaseService
                                                  .deleteFavoriteGroup([
                                                favGroupValue[index].name
                                              ]);
                                              if (widget.selected.value
                                                  .contains(index)) {
                                                final update =
                                                    List<int>.from(val);
                                                update.removeWhere((element) =>
                                                    element == index);
                                                widget.selected.value = update;
                                                widget.setLongPress.value = [];
                                                return;
                                              }
                                              //shift the slected index after delete
                                              for (int i = 0;
                                                  i <
                                                      widget.selected.value
                                                          .length;
                                                  i++) {
                                                if (widget.selected.value[i] >
                                                    index) {
                                                  widget.selected.value[i]--;
                                                }
                                              }

                                              widget.setLongPress.value = [];
                                            },
                                            icon: const Icon(MoonIcons
                                                .generic_delete_24_light),
                                            // label: const Text('Remove'),
                                          ),
                                          MoonButton.icon(
                                            iconColor: context
                                                .moonTheme
                                                ?.segmentedControlTheme
                                                .colors
                                                .backgroundColor,
                                            icon: const Icon(MoonIcons
                                                .generic_edit_24_regular),
                                            onTap: errorText.value == null
                                                ? () {
                                                    final oldname =
                                                        favGroupValue[index]
                                                            .name;
                                                    DatabaseService
                                                        .renameFavoriteGroup(
                                                            oldname,
                                                            textController
                                                                .text);
                                                    widget.setLongPress.value =
                                                        [];
                                                  }
                                                : null,
                                          )
                                        ])
                                  ],
                                ),
                                show: widget.setLongPress.value.contains(index),
                                child: MoonChip(
                                  onLongPress: () {
                                    textController.text =
                                        favGroupValue[index].name;
                                    widget.setLongPress.value = [index];
                                  },
                                  onTap: () {
                                    final update = List<int>.from(val);
                                    if (widget.selected.value.contains(index)) {
                                      update.remove(index);
                                      widget.selected.value = update;
                                      return;
                                    }
                                    update.add(index);
                                    widget.selected.value = update;
                                  },
                                  isActive: val.contains(index),
                                  gap: 5,
                                  label: Text(favGroupValue[index].name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "HarmonyOS_Sans")),
                                ))),
                        MoonPopover(
                            popoverPosition: MoonPopoverPosition.bottom,
                            onTapOutside: () => isShowAddPopUp.value = false,
                            show: isShowAddPopUp.value,
                            decoration: BoxDecoration(
                                color: context.moonTheme?.chipTheme.colors
                                    .backgroundColor,
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            maxWidth: 170,
                            content: Column(
                              children: [
                                Text('Add',
                                    style: TextStyle(
                                        color: context.moonTheme?.chipTheme
                                            .colors.textColor,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "HarmonyOS_Sans")),
                                const SizedBox(height: 20),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: MoonFormTextInput(
                                      errorText: errorText.value,
                                      inactiveBorderColor: Colors.transparent,
                                      hintText: 'Group Name',
                                      trailing: MoonButton.icon(
                                          onTap: () {
                                            textController.clear();
                                          },
                                          buttonSize: MoonButtonSize.sm,
                                          icon: const Icon(MoonIcons
                                              .controls_close_24_regular)),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "HarmonyOS_Sans"),
                                      // textInputSize:
                                      //     MoonTextInputSize.sm,
                                      controller: textController,
                                    )),
                                // const SizedBox(height: 10),
                                MoonButton.icon(
                                  iconColor: context
                                      .moonTheme
                                      ?.segmentedControlTheme
                                      .colors
                                      .backgroundColor,
                                  icon: const Text('Confirm'),
                                  onTap: errorText.value == null
                                      ? () {
                                          DatabaseService.putFavoriteGroup(
                                              textController.text);
                                          textController.clear();
                                          isShowAddPopUp.value = false;
                                          context.pop();
                                        }
                                      : null,
                                )
                              ],
                            ),
                            child: MoonButton(
                              backgroundColor: context
                                  .moonTheme?.chipTheme.colors.backgroundColor,
                              leading: const Icon(
                                  MoonIcons.controls_plus_24_regular),
                              onTap: () {
                                textController.clear();
                                isShowAddPopUp.value = !isShowAddPopUp.value;
                              },
                              label: const Text('ADD'),
                            ))
                      ],
                    ))
            // => CatergoryGroupChip(
            //       onLongPress: (p0) {},
            //       customOnTap: (val) {
            //         if (widget.isLongPress.value) {
            //           final update = List<int>.from(widget.setLongPress.value);
            //           if (widget.setLongPress.value.contains(val[0])) {
            //             update.remove(val[0]);
            //             widget.setLongPress.value = update;
            //             return widget.setSelected.value;
            //           }
            //           update.add(val[0]);
            //           widget.setLongPress.value = update;
            //           return widget.setSelected.value;
            //         }
            //         widget.setSelected.value = val;
            //         widget.selected.value = val;
            //         return val;
            //       },
            //       customOnLongPress: (p0) {
            //         if (!widget.isLongPress.value) {
            //           widget.isLongPress.value = true;
            //           widget.setLongPress.value = p0;
            //           return p0;
            //         }
            //         return widget.setLongPress.value;
            //       },
            //       setLongPress: widget.setLongPress,
            //       setSelected: widget.setSelected,
            //       items: favGroupValue.map((e) => e.name).toList(),
            //       onpress: (val) {},
            //       initSelected: const [],
            //       trailing: MoonButton(
            //         padding: const EdgeInsets.all(2),
            //         backgroundColor:
            //             context.moonTheme?.chipTheme.colors.backgroundColor,
            //         onTap: () {
            //           showMoonModal(
            //               context: context,
            //               builder: (context) {
            //                 return FavoriteAddGroupDialog(
            //                   onComplete: (p0) {
            //                     DatabaseService.putFavoriteGroup(p0);
            //                   },
            //                 );
            //               });
            //         },
            //         leading: const Icon(MoonIcons.controls_plus_24_regular),
            //       ),
            //     )
            )));
  }
}

class HomePage extends StatefulHookWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _categories = ['History', 'Favorite'];
  static final List<DateTime?> _times = [
    null,
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now().subtract(const Duration(days: 30)),
  ];
  static const List<ExtensionType?> _types = [
    null,
    ExtensionType.bangumi,
    ExtensionType.manga,
    ExtensionType.fikushon,
  ];
  int _selectedTime = 0;
  int _selectedType = 0;
  List<History> filterByDateAndCategory(DateTime? date, ExtensionType? type) {
    if (date == null && type == null) {
      return DatabaseService.db.historys
          .where()
          .sortByDateDesc()
          .limit(40)
          .findAllSync();
    }
    if (date != null && type != null) {
      return DatabaseService.db.historys
          .filter()
          .dateLessThan(date)
          .typeEqualTo(type)
          .findAllSync();
    }
    if (date == null) {
      return DatabaseService.db.historys
          .filter()
          .typeEqualTo(type!)
          .findAllSync();
    }
    return DatabaseService.db.historys
        .filter()
        .dateLessThan(date)
        .findAllSync();
  }

  final historyNotifier = HistoryChangeNotifier();
  final ValueNotifier<List<FavoriateGroup>> favGroup = ValueNotifier([]);
  final ValueNotifier<List<int>> setLongPress = ValueNotifier([]);
  final ValueNotifier<List<int>> setSelected = ValueNotifier([]);
  final ValueNotifier<List<int>> selected = ValueNotifier([]);
  @override
  Widget build(BuildContext context) {
    final controler = useTabController(initialLength: _categories.length);
    final isLongPress = useState(false);
    final setLongPress = useState(<int>[]);
    return MiruScaffold(
      // appBar: const MiruAppBar(
      //   // title: Text('Home'),
      // ),
      sidebar: (DeviceUtil.isMobileLayout(context))
          //mobile
          ? <Widget>[
              const SideBarListTitle(
                title: 'Home',
                // trailings: [
                //   if (isLongPress.value) ...[
                //     MoonButton.icon(
                //       icon: const Icon(MoonIcons.generic_delete_24_regular),
                //       onTap: () {
                //         FavoriteWarningDialog(
                //           selected: selected,
                //           setSelected: setSelected,
                //           setLongPress: setLongPress,
                //           group: favGroup,
                //           selectedToDelete: setLongPress,
                //         );
                //       },
                //     ),
                //     MoonButton.icon(
                //       icon: const Icon(MoonIcons.controls_close_24_regular),
                //       onTap: () {
                //         isLongPress.value = false;
                //         setLongPress.value = [];
                //       },
                //     )
                //   ]
                // ],
              ),
              const SideBarSearchBar(),
              const SizedBox(height: 10),
              MoonTabBar(
                tabController: controler,
                tabs: List.generate(
                  _categories.length,
                  (index) => MoonTab(
                    label: Text(_categories[index]),
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              SizedBox(
                  height: 300,
                  child: TabBarView(controller: controler, children: <Widget>[
                    DefaultTextStyle(
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "HarmonyOS_Sans"),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Time',
                                  ),
                                  CatergoryGroupChip(
                                      maxSelected: 1,
                                      minSelected: 1,
                                      items: const [
                                        'All',
                                        '1 day',
                                        '1 week',
                                        '1 month'
                                      ],
                                      onpress: (val) {
                                        _selectedTime = val[0];
                                        final history = filterByDateAndCategory(
                                            _times[_selectedTime],
                                            _types[_selectedType]);
                                        debugPrint(history.toString());
                                        historyNotifier.update(history);
                                      },
                                      initSelected: const [0]),
                                  const SizedBox(height: 10),
                                  const Text('Category'),
                                  CatergoryGroupChip(
                                      maxSelected: 1,
                                      minSelected: 1,
                                      items: const [
                                        'All',
                                        'Video',
                                        'Comic',
                                        'Novel'
                                      ],
                                      onpress: (val) {
                                        _selectedType = val[0];
                                        final history = filterByDateAndCategory(
                                            _times[_selectedTime],
                                            _types[_selectedType]);
                                        debugPrint(history.toString());
                                        historyNotifier.update(history);
                                      },
                                      initSelected: const [0]),
                                ]))),
                    FavoriteTab(
                      selected: selected,
                      setSelected: setSelected,
                      favGroup: favGroup,
                      setLongPress: setLongPress,
                      isLongPress: isLongPress,
                    ),
                  ])),
            ]
          : <Widget>[
              const SideBarListTitle(title: 'Home'),
              const SideBarSearchBar(),
              const SizedBox(height: 10),
              SidebarExpander(
                title: 'History',
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false, items: const ['ALL'], onpress: (val) {}),
              ),
              SidebarExpander(
                title: 'Type',
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false,
                    items: const ['ALL', 'Video', 'Comic', 'Novel'],
                    onpress: (val) {}),
              ),
              const SizedBox(height: 10),
              SidebarExpander(
                title: 'Favorite',
                actions: [
                  Button(
                    onPressed: () {},
                    child: const Icon(
                      Icons.add,
                      size: 15,
                    ),
                  ),
                ],
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false, items: const ['ALL'], onpress: (val) {}),
              ),
            ],
      body: PlatformWidget(
        mobileWidget: TabBarView(controller: controler, children: <Widget>[
          HistoryPage(historyNotifier: historyNotifier),
          FavoritePage(selected: selected),
        ]),
        desktopWidget: LayoutBuilder(
            builder: (context, cons) => Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: MoonTabBar.pill(
                            tabController: controler,
                            pillTabs: List.generate(
                                _categories.length,
                                (index) => MoonPillTab(
                                    tabStyle: MoonPillTabStyle(
                                        selectedTextColor: context
                                            .moonTheme
                                            ?.segmentedControlTheme
                                            .colors
                                            .selectedSegmentColor,
                                        textStyle:
                                            const TextStyle(fontSize: 20)),
                                    label: Text(_categories[index]))))),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        child: TabBarView(
                            controller: controler,
                            children: <Widget>[
                          HistoryPage(historyNotifier: historyNotifier),
                          FavoritePage(selected: selected),
                        ]))
                  ],
                )),
      ),
    );
  }
}

// class DesktopHistoryPage extends StatelessWidget {
//   final HistoryChangeNotifier historyNotifier;
//   const DesktopHistoryPage({super.key, required this.historyNotifier});
//   @override
//   Widget build(BuildContext context) {}
// }
