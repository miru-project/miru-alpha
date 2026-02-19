import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/model/user_data.dart';
import 'package:miru_app_new/provider/favorite_page_provider.dart';
import 'package:miru_app_new/utils/store/database_service.dart';

class FavoriteTab extends StatefulHookConsumerWidget {
  const FavoriteTab({super.key});

  @override
  createState() => _FavoriteTabState();
}

class _FavoriteTabState extends ConsumerState<FavoriteTab> {
  final ValueNotifier<List<FavoriteGroup>> favGroup = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  Future<void> _refreshGroups() async {
    favGroup.value = await DatabaseService.getAllFavoriteGroup();
  }

  String text = '';
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final errorText = useState<String?>(null);
    final isCreating = useState(false);
    final textFieldKey = useState(UniqueKey());
    final selectDuration = useState<String?>('All');
    textController.addListener(() {
      text = textController.text;
      if (text.isEmpty) {
        errorText.value = 'Name is empty';
        return;
      }
      if (favGroup.value.any((element) => element.name == text)) {
        errorText.value = 'Same name exists';
        return;
      }
      errorText.value = null;
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Favorites",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              const Spacer(),
              if (!isCreating.value)
                FButton(
                  variant: .outline,
                  onPress: () {
                    isCreating.value = true;
                    textController.clear();
                    textFieldKey.value = UniqueKey();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FIcons.plus),
                      SizedBox(width: 4),
                      Text("New Tag"),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              SizedBox(
                width: 400,
                height: 60,
                child: FTabs(
                  scrollable: false,
                  physics: null,
                  onPress: (value) {
                    final Set<ExtensionType> type = {};
                    switch (value) {
                      case 1:
                        type.add(ExtensionType.bangumi);
                        break;
                      case 2:
                        type.add(ExtensionType.manga);
                        break;
                      case 3:
                        type.add(ExtensionType.fikushon);
                        break;
                    }
                    ref
                        .read(favoritePageProvider.notifier)
                        .filterWithType(type);
                  },
                  children: [
                    FTabEntry(label: Text('All'), child: SizedBox.shrink()),
                    FTabEntry(label: Text('Video'), child: SizedBox.shrink()),
                    FTabEntry(label: Text('Manga'), child: SizedBox.shrink()),
                    FTabEntry(label: Text('Novel'), child: SizedBox.shrink()),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: FSelect<String>.rich(
                      control: .lifted(
                        value: selectDuration.value,
                        onChange: (newValue) {
                          selectDuration.value = newValue;
                          late final Duration duration;
                          switch (newValue) {
                            case 'All':
                              duration = const Duration(days: 36500);
                              break;
                            case 'Day':
                              duration = const Duration(days: 1);
                              break;
                            case 'Week':
                              duration = const Duration(days: 7);
                              break;
                            case 'Month':
                              duration = const Duration(days: 30);
                              break;
                            case 'Year':
                              duration = const Duration(days: 365);
                              break;
                          }
                          ref
                              .read(favoritePageProvider.notifier)
                              .filterWithDuration(duration);
                        },
                      ),
                      prefixBuilder: (context, style, states) => Padding(
                        padding: const .only(left: 14, right: 8),
                        child: Text(
                          "Sort:",
                          style: style.emptyTextStyle.copyWith(
                            color: context.theme.colors.foreground,
                          ),
                        ),
                      ),
                      hint: 'Time',
                      format: (s) => s,
                      children: [
                        for (final sort in [
                          'All',
                          'Day',
                          'Week',
                          'Month',
                          'Year',
                        ])
                          FSelectItem(title: Text(sort), value: sort),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FButton(
                    onPress: () {},
                    variant: .outline,
                    prefix: Icon(FIcons.listFilter),
                    child: Text('More filter'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
