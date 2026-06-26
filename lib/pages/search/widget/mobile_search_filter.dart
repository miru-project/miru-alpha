import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class MobileSearchFilter extends HookConsumerWidget {
  const MobileSearchFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: useSingleTickerProvider(),
    );
    final searchState = ref.watch(searchPageProvider);
    final notifier = ref.read(searchPageProvider.notifier);
    final metaData = ref.watch(extensionPageProvider).metaData;

    // Load iso.json and build language entries
    final isoMap = useState<Map<String, dynamic>>({});
    useEffect(() {
      rootBundle.loadString('assets/iso.json').then((data) {
        isoMap.value = jsonDecode(data) as Map<String, dynamic>;
      });
      return null;
    }, []);

    // Sort and sanitize unique language codes from metadata
    final langEntries = useMemoized(() {
      final uniqueLangs = <String>{};
      for (final e in metaData) {
        if (e.lang.isNotEmpty) {
          final base = e.lang.split(RegExp(r'[-_]')).first;
          uniqueLangs.add(base);
        }
      }
      final sorted = uniqueLangs.toList()..sort();
      return [
        MapEntry('', 'common.all'.i18n),
        ...sorted.map((rawCode) {
          final baseCode = rawCode.split(RegExp(r'[-_]')).first;
          final displayName = () {
            final isoEntry = isoMap.value[baseCode];
            if (isoEntry is Map && isoEntry['name'] is String) {
              return isoEntry['name'] as String;
            }
            return baseCode;
          }();
          return MapEntry(baseCode, displayName);
        }),
      ];
    }, [metaData, isoMap.value]);

    // Type options for dropdown
    final typeEntries = <MapEntry<String, ExtensionType?>>[
      MapEntry('common.all'.i18n, null),
      MapEntry('media.bangumi'.i18n, ExtensionType.bangumi),
      MapEntry('media.manga'.i18n, ExtensionType.manga),
      MapEntry('media.novel'.i18n, ExtensionType.fikushon),
    ];

    // Format type selection value to label
    String formatType(ExtensionType? t) {
      return switch (t) {
        ExtensionType.bangumi => 'media.bangumi'.i18n,
        ExtensionType.manga => 'media.manga'.i18n,
        ExtensionType.fikushon => 'media.novel'.i18n,
        _ => 'common.all'.i18n,
      };
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FButton(
          variant: .outline,
          mainAxisAlignment: .spaceBetween,
          prefix: Icon(FLucideIcons.listFilter),
          suffix: AnimatedRotation(
            turns: expanded.value ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(FLucideIcons.chevronDown, size: 18),
          ),
          onPress: () {
            if (expanded.value) {
              controller.reverse();
            } else {
              controller.forward();
            }
            expanded.value = !expanded.value;
          },
          child: Expanded(
            child: Padding(
              padding: .symmetric(horizontal: 10),
              child: Row(
                children: [
                  SizedBox(height: 10),
                  Text('common.filters'.i18n),
                  if (searchState.selectedLang != null ||
                      (searchState.selectedType != null &&
                          searchState.selectedType != ExtensionType.all)) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.theme.colors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${searchState.selectedLang != null ? 1 : 0}',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.theme.colors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) => SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  // Type Dropdown
                  Expanded(
                    child: FSelect<ExtensionType?>.rich(
                      label: Text('common.type'.i18n),
                      hint: 'common.all'.i18n,
                      format: (v) => formatType(v),
                      control: .lifted(
                        value: searchState.selectedType,
                        onChange: (v) => notifier.setSelectedType(v),
                      ),
                      children: typeEntries.map((entry) {
                        return FSelectItem(
                          title: Text(entry.key),
                          value: entry.value,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Language Dropdown
                  Expanded(
                    child: FSelect<String>.rich(
                      label: Text('common.language'.i18n),
                      hint: 'common.laguage'.i18n,
                      format: (v) => langEntries
                          .firstWhere(
                            (e) => e.key == v,
                            orElse: () => MapEntry(v, v),
                          )
                          .value,
                      control: .lifted(
                        value: searchState.selectedLang ?? '',
                        onChange: (v) => notifier.setSelectedLang(
                          v == null || v.isEmpty ? null : v,
                        ),
                      ),
                      children: langEntries.map((entry) {
                        return FSelectItem(
                          title: Text(entry.value),
                          value: entry.key,
                        );
                      }).toList(),
                    ),
                  ),

                  Padding(
                    padding: .only(left: 10, top: 10),
                    child: FButton.icon(
                      variant: .ghost,
                      onPress: () {},
                      child: Icon(FLucideIcons.pin, size: 25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
