/// Mirrors test/ui/features/search/*_test.dart states for the catalog.
///
/// One component per widget under test:
/// - desktop_search_list_tile_test -> DesktopSearchListTile
/// - filter_dialog_panel_test -> ExtensionFilterPanel
/// - filter_dialog_shell_test -> SearchFilterDialog
/// - filter_select_controls_test -> FilterSelectField, FilterMultiSelectField
/// - filter_text_field_test -> FilterTextField, ExtensionFilterBody
/// - mobile_filter_summary_chip_test -> MobileFilterSummaryChip
/// - mobile_search_page_test -> MobileSearchPage, MobileSearchInputPage,
///   MobileSearchResultsBody, MobileSearchScopeSummary, settings sheet
/// - search_desktop_content_repro_test / search_view_widget_test -> SearchView
///
/// Skipped states (behaviour-only or no renderable fake):
/// - segmentedFits fit-rule maths (pure function, no visual state).
/// - the filter dialog's system-back exit (skipped in the test itself; the
///   route observer is WIP).
/// - provider behaviour: Recent Searches cap, typing-vs-Enter fetch gating,
///   staged-vs-committed assertions, pagination predictor / latch / refresh,
///   scope defaults, orderGlobalResults, ExtensionFilterView normalisation —
///   the interactive use-cases exercise the same paths live.
/// - dark-theme re-renders: the catalog ThemeAddon renders every use-case
///   under the selected theme.
/// - the hidden-source management view: reachable live via the tab's Status
///   pill; the test pumps no fixed state beyond the source list itself.
///
/// i18n renders raw keys (no delegates mounted), exactly like the widget
/// tests. The FTheme comes from the catalog's ThemeAddon; MiruScaffold
/// re-applies the fake ApplicationController's theme, which is seeded with
/// the theme selected in the catalog. Full-screen mobile layouts render
/// inside PhoneFrame; desktop surfaces render bare (pick a viewport wider
/// than the theme's `lg` breakpoint for the desktop branch).
library;

import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/domain/models/search.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    hide ExtensionFilter, ExtensionListItem;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/search/global_search_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/core/dialog/dialog.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_input_page.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_page.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_results.dart';
import 'package:miru_alpha/ui/features/search/view_models/search_view_model.dart';
import 'package:miru_alpha/ui/features/search/views/search_view.dart';
import 'package:miru_alpha/ui/features/search/widget/desktop_search_list_tile.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_dialog_panel.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_select_controls.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_text_tile.dart';
import 'package:miru_alpha/ui/features/search/widget/mobile_filter_summary_chip.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_dialog.dart';
import 'package:miru_alpha/ui/features/search/widget/search_page_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_results_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_settings_sheet.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// The mirrored search-area folder: every widget state the
/// `test/ui/features/search` suite pumps, rendered with the tests' own fakes.
WidgetbookFolder buildSearchMirroredFolder() {
  // The source-list surfaces read settings synchronously during build (the
  // NSFW filter, the pinned/hidden sets); seed the shipped defaults the way
  // the app's bootstrap does, so those reads resolve instead of returning null.
  MiruSettings.seedDefaults();
  return WidgetbookFolder(
    name: 'Search (mirrored)',
    children: [
      _desktopTileComponent(),
      _filterPanelComponent(),
      _filterDialogComponent(),
      _filterSelectComponent(),
      _filterMultiSelectComponent(),
      _filterTextFieldComponent(),
      _filterBodyComponent(),
      _summaryChipComponent(),
      _mobileSearchPageComponent(),
      _mobileSearchInputComponent(),
      _searchResultsComponent(),
      _scopeSummaryComponent(),
      _settingsSheetComponent(),
      _searchViewComponent(),
    ],
  );
}

// ---------------------------------------------------------------------------
// desktop_search_list_tile_test
// ---------------------------------------------------------------------------

WidgetbookComponent _desktopTileComponent() {
  return WidgetbookComponent(
    name: 'DesktopSearchListTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Failed extension (error line)',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 560,
            child: DesktopSearchListTile(
              ext: _meta('bad.pkg', 'Broken', error: _loadError),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Not-yet-loaded extension',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 560,
            child: DesktopSearchListTile(
              ext: _meta('empty.pkg', 'Empty', api: ''),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Healthy extension',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 560,
            child: DesktopSearchListTile(ext: _meta('ok.pkg', 'Fine')),
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// filter_dialog_panel_test
// ---------------------------------------------------------------------------

WidgetbookComponent _filterPanelComponent() {
  return WidgetbookComponent(
    name: 'ExtensionFilterPanel',
    useCases: [
      WidgetbookUseCase(
        name: 'All filter variants (flat sections)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'type': _select({
                'all': 'All',
                'airing': 'Airing',
                'completed': 'Completed',
                'upcoming': 'Upcoming',
              }),
              'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
              'uploader': _text(),
              'year': _range(),
            },
            child: _panelBox(420),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Empty catalogue (no-filter message)',
        builder: (context) => catalogFrame(
          _singleScope(filters: const {}, child: _panelBox(420)),
        ),
      ),
      WidgetbookUseCase(
        name: 'Text filter (title rendered once)',
        builder: (context) => catalogFrame(
          _singleScope(filters: {'uploader': _text()}, child: _panelBox(420)),
        ),
      ),
      WidgetbookUseCase(
        name: 'Multi-select with selection count',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
            },
            selected: const {
              'genre': ['fantasy'],
            },
            child: _panelBox(420),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Multi-select with no selection (count hidden)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'genre': _multi({'action': 'Action'}),
            },
            child: _panelBox(420),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Staged chip toggle (draft only)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
            },
            staging: true,
            child: _panelBox(420),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Staged dropdown pick (draft only)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'sort': _select({
                'size': 'Size',
                'id': 'Id',
                'seeders': 'Seeders',
                'leechers': 'Leechers',
                'downloads': 'Downloads',
              }, title: 'Sort'),
            },
            staging: true,
            child: _panelBox(700),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Two-option select (switch row)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'sub': _select(
                {'off': 'No Subs', 'on': 'Subs Only'},
                def: 'off',
                title: 'Subs',
              ),
            },
            selected: const {
              'sub': ['off'],
            },
            staging: true,
            child: _panelBox(420),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Two dropdowns side by side (wide panel)',
        builder: (context) => catalogFrame(
          _singleScope(filters: _twoLongDropdowns(), child: _panelBox(760)),
        ),
      ),
      // The test's 340px stack relies on the test font's fixed glyph widths;
      // proportional fonts measure narrower, so 340 pairs live. 280 keeps the
      // stacked state the test asserts.
      WidgetbookUseCase(
        name: 'Two dropdowns stacked (narrow panel)',
        builder: (context) => catalogFrame(
          _singleScope(filters: _twoLongDropdowns(), child: _panelBox(280)),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// filter_dialog_shell_test
// ---------------------------------------------------------------------------

WidgetbookComponent _filterDialogComponent() {
  return WidgetbookComponent(
    name: 'SearchFilterDialog',
    useCases: [
      WidgetbookUseCase(
        name: 'Header + flat panel (tap to open)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
            },
            child: SizedBox(width: 480, height: 360, child: _dialogApp()),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Fits a phone (open via button)',
        builder: (context) => _singleScope(
          filters: {
            'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
          },
          child: PhoneFrame(child: _dialogApp()),
        ),
      ),
    ],
  );
}

/// The dialog host the test drives: an `open` button that goes through the
/// app's real `showMiruDialog` entry, as `search_page_single_view` does.
Widget _dialogApp() {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => _openFilterDialog(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void _openFilterDialog(BuildContext context) {
  showMiruDialog<bool>(
    context: context,
    builder: (context, style, animation) => FTheme(
      data: context.theme,
      child: SearchFilterDialog(style: style, animation: animation),
    ),
  );
}

// ---------------------------------------------------------------------------
// filter_select_controls_test
// ---------------------------------------------------------------------------

WidgetbookComponent _filterSelectComponent() {
  return WidgetbookComponent(
    name: 'FilterSelectField',
    useCases: [
      WidgetbookUseCase(
        name: 'Segmented strip (4 options fit)',
        builder: (context) => catalogFrame(
          _FilterSelectDemo(
            width: 480,
            filter: _select({
              'all': 'All',
              'airing': 'Airing',
              'completed': 'Completed',
              'upcoming': 'Upcoming',
            }).select,
            initialSelected: const ['completed'],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Dropdown (5+ options)',
        builder: (context) => catalogFrame(
          _FilterSelectDemo(
            width: 420,
            filter: _select({
              'size': 'Size',
              'id': 'Id',
              'seeders': 'Seeders',
              'leechers': 'Leechers',
              'downloads': 'Complete Downloads',
              'comments': 'Comments',
            }, title: 'Sort').select,
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Dropdown (5+ long labels)',
        builder: (context) => catalogFrame(
          _FilterSelectDemo(
            width: 420,
            filter: _select({
              'a': 'Anime Series',
              'b': 'Live Action',
              'c': 'Documentary',
              'd': 'Music Video',
              'e': 'Short Film',
            }, title: 'Kind').select,
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Two options (switch row)',
        builder: (context) => catalogFrame(
          _FilterSelectDemo(
            width: 420,
            filter: _select(
              {'off': 'No Subs', 'on': 'Subs Only'},
              def: 'off',
              title: 'Subs',
            ).select,
            initialSelected: const ['off'],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Empty options (renders nothing)',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 300,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: context.theme.colors.border),
              ),
              child: FilterSelectField(
                filter: _select(const {}).select,
                selected: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Narrow container falls back to dropdown',
        builder: (context) => catalogFrame(
          _FilterSelectDemo(
            width: 200,
            filter: _select({
              'all': 'All',
              'airing': 'Airing',
              'completed': 'Completed',
              'upcoming': 'Upcoming',
            }).select,
          ),
        ),
      ),
    ],
  );
}

WidgetbookComponent _filterMultiSelectComponent() {
  return WidgetbookComponent(
    name: 'FilterMultiSelectField',
    useCases: [
      WidgetbookUseCase(
        name: 'Unselected pills (no count)',
        builder: (context) => catalogFrame(
          _FilterMultiSelectDemo(
            options: const [
              ExtensionFilterOptionEntry('action', 'Action'),
              ExtensionFilterOptionEntry('fantasy', 'Fantasy'),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Selected pills (tap to toggle)',
        builder: (context) => catalogFrame(
          _FilterMultiSelectDemo(
            options: const [
              ExtensionFilterOptionEntry('action', 'Action'),
              ExtensionFilterOptionEntry('fantasy', 'Fantasy'),
              ExtensionFilterOptionEntry('adventure', 'Adventure'),
            ],
            initialSelected: const ['fantasy', 'adventure'],
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// filter_text_field_test
// ---------------------------------------------------------------------------

WidgetbookComponent _filterTextFieldComponent() {
  return WidgetbookComponent(
    name: 'FilterTextField',
    useCases: [
      WidgetbookUseCase(
        name: 'Inline field (title + generic placeholder)',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 320,
            child: FilterTextField(
              filter: _text(title: 'Author', hint: '').text,
              value: '',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Hint as placeholder',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 320,
            child: FilterTextField(
              filter: _text(title: 'Author', hint: 'e.g. Fujimoto').text,
              value: '',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Seeded value',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 320,
            child: FilterTextField(
              filter: _text(title: 'Author', hint: '').text,
              value: 'Fujimoto',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ],
  );
}

WidgetbookComponent _filterBodyComponent() {
  return WidgetbookComponent(
    name: 'ExtensionFilterBody',
    useCases: [
      WidgetbookUseCase(
        name: 'Text filter renders a field (not chips)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {'author': _text(title: 'Author', hint: 'e.g. Fujimoto')},
            child: _bodyBox(),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Text beside two-option select (switch row)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'type': _select({'all': 'All', 'manga': 'Manga'}, title: 'Type'),
              'author': _text(title: 'Author', hint: ''),
            },
            child: _bodyBox(),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Typed value shows the count badge',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {'author': _text(title: 'Author', hint: 'e.g. Fujimoto')},
            selected: const {
              'author': ['Fujimoto'],
            },
            child: _bodyBox(),
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// mobile_filter_summary_chip_test
// ---------------------------------------------------------------------------

WidgetbookComponent _summaryChipComponent() {
  return WidgetbookComponent(
    name: 'MobileFilterSummaryChip',
    useCases: [
      WidgetbookUseCase(
        name: 'Two selected (labels only)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {'genre': _multi(_genreOptions, title: 'Genre')},
            selected: const {
              'genre': ['action', 'comedy'],
            },
            child: _summaryHeader(),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Four selected (+2 badge)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {'genre': _multi(_genreOptions, title: 'Genre')},
            selected: const {
              'genre': ['action', 'comedy', 'drama', 'fantasy'],
            },
            child: _summaryHeader(),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Long labels (+1, header intact)',
        builder: (context) => catalogFrame(
          _singleScope(
            filters: {
              'genre': _multi(const {
                'a': 'Unboundedly long option label',
                'b': 'Another very long option label',
                'c': 'Third long option label',
              }, title: 'Genre'),
            },
            selected: const {
              'genre': ['a', 'b', 'c'],
            },
            child: _summaryHeader(),
          ),
        ),
      ),
    ],
  );
}

/// The `/search/single` header row the chip lives in: fixed back-button box,
/// flexible title, then the summary. Overflowing this row is what the chip
/// must never do.
Widget _summaryHeader() {
  return SizedBox(
    width: 383,
    height: 40,
    child: Row(
      children: [
        const SizedBox(width: 52),
        const Expanded(
          child: Text('ExampleB (Go variant)', overflow: TextOverflow.ellipsis),
        ),
        MobileFilterSummaryChip(onTap: () {}),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// mobile_search_page_test
// ---------------------------------------------------------------------------

WidgetbookComponent _mobileSearchPageComponent() {
  return WidgetbookComponent(
    name: 'MobileSearchPage',
    useCases: [
      WidgetbookUseCase(
        name: 'Search tab (title, sources, pills)',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: _demoSources(),
          child: _phoneApp(const MobileSearchPage()),
        ),
      ),
      WidgetbookUseCase(
        name: 'Pinned source cards (unpin affordance)',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: _demoSources(),
          pinned: const {'a.pkg'},
          child: _phoneApp(const MobileSearchPage()),
        ),
      ),
      WidgetbookUseCase(
        name: 'Long source list (pinned pills stay)',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: [for (var i = 0; i < 14; i++) _meta('p$i.pkg', 'Source $i')],
          child: _phoneApp(const MobileSearchPage()),
        ),
      ),
    ],
  );
}

WidgetbookComponent _mobileSearchInputComponent() {
  return WidgetbookComponent(
    name: 'MobileSearchInputPage',
    useCases: [
      WidgetbookUseCase(
        name: 'Recents + scope / type / sort (interactive)',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: _demoSources(),
          history: const ['Frieren', 'Berserk'],
          child: _phoneApp(
            const MobileSearchPage(),
            initialLocation: '/search/input',
          ),
        ),
      ),
    ],
  );
}

WidgetbookComponent _searchResultsComponent() {
  return WidgetbookComponent(
    name: 'MobileSearchResultsBody',
    useCases: [
      WidgetbookUseCase(
        name: 'Flat relevance grid',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: _demoSources(),
          aggregate: GlobalSearchAggregate(
            entries: [
              _entry(
                _meta('a.pkg', 'ExampleA'),
                'Frieren: Beyond Journey',
                update: '2026-01-02 10:00',
              ),
              _entry(
                _meta('b.pkg', 'ExampleC', type: ExtensionType.manga),
                'Frieren manga',
              ),
            ],
            done: 2,
            total: 2,
            failed: const [],
          ),
          child: _phoneApp(const _ResultsScreen()),
        ),
      ),
      WidgetbookUseCase(
        name: 'By-extension shelves + empty footer',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: _demoSources(),
          viewMode: ResultsViewMode.byExtension,
          aggregate: GlobalSearchAggregate(
            entries: [
              _entry(_meta('a.pkg', 'ExampleA'), 'Frieren: Beyond Journey'),
              _entry(
                _meta('b.pkg', 'ExampleC', type: ExtensionType.manga),
                'Frieren manga',
              ),
            ],
            done: 2,
            total: 3,
            failed: const [],
          ),
          child: _phoneApp(const _ResultsScreen()),
        ),
      ),
      WidgetbookUseCase(
        name: 'Failed source (retry row)',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: _demoSources(),
          aggregate: GlobalSearchAggregate(
            entries: [_entry(_meta('a.pkg', 'ExampleA'), 'Frieren')],
            done: 1,
            total: 2,
            failed: const ['ExampleD'],
            failedPackages: const ['royal.pkg'],
          ),
          child: _phoneApp(const _ResultsScreen()),
        ),
      ),
      WidgetbookUseCase(
        name: 'Skeletons while next page is in flight',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: _demoSources(),
          aggregate: GlobalSearchAggregate(
            entries: [_entry(_meta('a.pkg', 'ExampleA'), 'Frieren')],
            done: 1,
            total: 1,
            failed: const [],
            hasMore: true,
          ),
          child: _phoneApp(const _ResultsScreen()),
        ),
      ),
    ],
  );
}

/// The results state of `/search/input`, composed from the page's own public
/// pieces: the results header sliver over `MobileSearchResultsBody`.
class _ResultsScreen extends HookConsumerWidget {
  const _ResultsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: 'Frieren');
    final focusNode = useFocusNode();
    return MiruScaffold.mobile(
      sliverHeaders: [
        searchHeaderSliver(
          context,
          extent: 148,
          child: SearchResultsHeader(
            controller: controller,
            focusNode: focusNode,
            onSubmit: (value) {},
            onBack: () {},
          ),
        ),
      ],
      body: const MobileSearchResultsBody(query: 'Frieren'),
    );
  }
}

WidgetbookComponent _scopeSummaryComponent() {
  return WidgetbookComponent(
    name: 'MobileSearchScopeSummary',
    useCases: [
      WidgetbookUseCase(
        name: 'All-sources scope pill',
        builder: (context) => catalogFrame(
          _tabScope(
            theme: context.theme,
            metas: _demoSources(),
            child: _scopePillBox(),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Pinned scope pill',
        builder: (context) => catalogFrame(
          _tabScope(
            theme: context.theme,
            metas: _demoSources(),
            pinned: const {'a.pkg'},
            scopeMode: SearchScopeMode.pinned,
            child: _scopePillBox(),
          ),
        ),
      ),
    ],
  );
}

WidgetbookComponent _settingsSheetComponent() {
  return WidgetbookComponent(
    name: 'Search settings sheet',
    useCases: [
      WidgetbookUseCase(
        name: 'Edit Filters sheet (tap to open)',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: _demoSources(),
          child: MaterialApp.router(
            routerConfig: _searchRouter(
              initialLocation: '/',
              rootKey: true,
              rootPage: Scaffold(
                body: Center(
                  child: FButton(
                    onPress: () => unawaited(showSearchSettingsSheet()),
                    child: const Text('open sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// search_desktop_content_repro_test / search_view_widget_test
// ---------------------------------------------------------------------------

WidgetbookComponent _searchViewComponent() {
  return WidgetbookComponent(
    name: 'SearchView',
    useCases: [
      WidgetbookUseCase(
        name: 'Desktop: installed tiles',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: [_meta('a.pkg', 'Alpha'), _meta('b.pkg', 'Beta')],
          child: _routerApp(const SearchView()),
        ),
      ),
      WidgetbookUseCase(
        name: 'Desktop: empty installed list',
        builder: (context) => _tabScope(
          theme: context.theme,
          metas: const [],
          child: _routerApp(const SearchView()),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Harness: the same fake values the mirrored tests build.
// ---------------------------------------------------------------------------

/// The backend load error the tile test asserts against.
const _loadError =
    'package name does not match the file name\r\n'
    ' file name: not_the_package_name.js\r\n'
    ' package name: some-package';

const _genreOptions = {
  'action': 'Action',
  'comedy': 'Comedy',
  'drama': 'Drama',
  'fantasy': 'Fantasy',
};

ExtensionMeta _meta(
  String pkg,
  String name, {
  String? error,
  String api = 'v2',
  bool nsfw = false,
  ExtensionType type = ExtensionType.bangumi,
  String? description,
}) => ExtensionMeta(
  name: name,
  version: '2.0.0',
  author: 't',
  license: 'MIT',
  lang: 'en',
  packageName: pkg,
  webSite: 'https://example.com',
  description: description,
  tags: const [],
  api: api,
  type: type,
  error: error,
  nsfw: nsfw,
);

List<ExtensionMeta> _demoSources() => [
  _meta('a.pkg', 'ExampleA'),
  _meta('b.pkg', 'ExampleC', type: ExtensionType.manga),
  _meta('c.pkg', 'ExampleB'),
];

ExtensionFilter _select(
  Map<String, String> options, {
  String def = '',
  String title = 'Status',
}) => ExtensionFilter()
  ..select = (SelectFilter()
    ..title = title
    ..default_2 = def
    ..options.addAll({
      for (final e in options.entries) e.key: (FilterOption()..label = e.value),
    }));

ExtensionFilter _multi(
  Map<String, String> options, {
  List<String> def = const [],
  String title = 'Genres',
}) => ExtensionFilter()
  ..multiSelect = (MultiSelectFilter()
    ..title = title
    ..min = 1
    ..max = 8
    ..default_4.addAll(def)
    ..options.addAll({
      for (final e in options.entries) e.key: (FilterOption()..label = e.value),
    }));

ExtensionFilter _text({
  String def = '',
  String title = 'Uploader',
  String hint = 'e.g. subsplease',
}) => ExtensionFilter()
  ..text = (TextFilter()
    ..title = title
    ..default_2 = def
    ..hint = hint);

ExtensionFilter _range() => ExtensionFilter()
  ..range = (RangeFilter()
    ..title = 'Year'
    ..min = 1990
    ..max = 2025
    ..defaultMin = 2000
    ..defaultMax = 2025);

Map<String, ExtensionFilter> _twoLongDropdowns() => {
  'format': ExtensionFilter()
    ..select = (SelectFilter()
      ..title = 'Format'
      ..options.addAll({
        for (final k in ['tv', 'movie', 'ova', 'ona', 'special'])
          k: (FilterOption()..label = 'Feature Length'),
      })),
  'sort': ExtensionFilter()
    ..select = (SelectFilter()
      ..title = 'Sort'
      ..options.addAll({
        for (final k in ['a', 'b', 'c', 'd', 'e'])
          k: (FilterOption()..label = 'Download Popularity'),
      })),
};

GlobalSearchEntry _entry(
  ExtensionMeta meta,
  String title, {
  String update = '',
}) => GlobalSearchEntry(
  meta: meta,
  item: (ExtensionListItem()
    ..title = title
    ..url = 'https://example.com/item'
    ..update = update),
  sourcePinned: true,
  origin: 0,
);

class _FakeSingle extends SearchPageSingleProvider {
  _FakeSingle(this.filters, {this.selected = const {}, this.staging = false});

  final Map<String, ExtensionFilter> filters;
  final Map<String, List<String>> selected;
  final bool staging;

  @override
  SingleSearchPageState build() {
    // Staging is the dialog's policy (`SearchFilterDialog.initState`); the
    // bare panel runs without it, like the desktop overlay.
    if (staging) beginFilterStaging();
    return SingleSearchPageState(
      filter: filters,
      filterOrder: filters.keys.toList(),
      selected: selected,
    );
  }
}

class _FakeTabSearch extends SearchPageNotifier {
  _FakeTabSearch(
    this.metas, {
    this.pinned = const {},
    this.history = const [],
    this.viewMode = ResultsViewMode.relevance,
    this.scopeMode = SearchScopeMode.all,
  });

  final List<ExtensionMeta> metas;
  final Set<String> pinned;
  final List<String> history;
  final ResultsViewMode viewMode;
  final SearchScopeMode scopeMode;

  @override
  SearchPageState build() => SearchPageState(
    metaData: metas,
    pinnedExtensions: {},
    query: '',
    existedPinnedExtensions: pinned,
    scopeMode: scopeMode,
    history: history,
    resultsViewMode: viewMode,
  );
}

class _FakeAppController extends ApplicationController {
  _FakeAppController(this._state);

  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

class _FakeHistoryPage extends HistoryPageNotifier {
  @override
  HistoryPageState build() =>
      HistoryPageState(history: const [], filteredHistory: const []);
}

class _FakeFavoritePage extends FavoritePageNotifier {
  @override
  FavoritePageState build() => FavoritePageState(
    favorites: const [],
    favoriteGroups: const [],
    filteredFavorites: const [],
    selectedFavoriteGroups: const [],
  );
}

class _FakeSearchViewModel extends SearchViewModel {
  @override
  Future<DomainSearchState> build() => Future.value(
    const DomainSearchState(extensions: [], query: '', isLoading: false),
  );
}

ApplicationState _appState(FThemeData theme) => ApplicationState(
  themeText: 'light',
  baseColor: 'zinc',
  primaryColor: 'zinc',
  themeData: theme,
  themeMode: ThemeMode.light,
  language: 'en',
);

/// The single-extension filter providers the filter panel / dialog / body
/// tests override.
Widget _singleScope({
  required Map<String, ExtensionFilter> filters,
  Map<String, List<String>> selected = const {},
  bool staging = false,
  required Widget child,
}) => ProviderScope(
  overrides: [
    searchPageSingleProviderProvider.overrideWith(
      () => _FakeSingle(filters, selected: selected, staging: staging),
    ),
  ],
  child: child,
);

/// The global-search page providers the mobile search tests override.
Widget _tabScope({
  required FThemeData theme,
  required List<ExtensionMeta> metas,
  Set<String> pinned = const {},
  List<String> history = const [],
  ResultsViewMode viewMode = ResultsViewMode.relevance,
  SearchScopeMode scopeMode = SearchScopeMode.all,
  GlobalSearchAggregate? aggregate,
  required Widget child,
}) => ProviderScope(
  overrides: [
    searchPageProvider.overrideWith(
      () => _FakeTabSearch(
        metas,
        pinned: pinned,
        history: history,
        viewMode: viewMode,
        scopeMode: scopeMode,
      ),
    ),
    applicationControllerProvider.overrideWith(
      () => _FakeAppController(_appState(theme)),
    ),
    searchViewModelProvider.overrideWith(_FakeSearchViewModel.new),
    historyPageProvider.overrideWith(_FakeHistoryPage.new),
    favoritePageProvider.overrideWith(_FakeFavoritePage.new),
    if (aggregate != null)
      globalSearchAggregateProvider.overrideWith((ref) => aggregate),
  ],
  child: child,
);

/// The routes the mirrored pages push to, stubbed like the tests'.
GoRouter _searchRouter({
  required String initialLocation,
  required Widget rootPage,
  bool rootKey = false,
}) => GoRouter(
  navigatorKey: rootKey ? RouterUtil.rootNavigatorKey : null,
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/', builder: (context, state) => rootPage),
    GoRoute(
      path: '/search/input',
      builder: (context, state) => const MobileSearchInputPage(),
    ),
    GoRoute(
      path: '/search/single',
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
    ),
    GoRoute(
      path: '/search/single/detail',
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
    ),
    GoRoute(
      path: '/extensionSettings',
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
    ),
    GoRoute(
      path: '/mobileWebView',
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
    ),
  ],
);

/// A phone-sized canvas running the app's real routing, the way the mobile
/// search tests pump these pages (420x900 surface, GoRouter beneath).
Widget _phoneApp(Widget rootPage, {String initialLocation = '/'}) {
  return PhoneFrame(
    child: MaterialApp.router(
      routerConfig: _searchRouter(
        initialLocation: initialLocation,
        rootPage: rootPage,
      ),
    ),
  );
}

/// The desktop SearchView's router shell: the viewport addon picks the size,
/// so the app renders bare (wider than the theme's `lg` breakpoint).
Widget _routerApp(Widget rootPage) {
  return MaterialApp.router(
    routerConfig: _searchRouter(initialLocation: '/', rootPage: rootPage),
  );
}

Widget _panelBox(double width) =>
    SizedBox(width: width, child: const ExtensionFilterPanel());

Widget _bodyBox() => SizedBox(width: 420, child: const ExtensionFilterBody());

Widget _scopePillBox() =>
    SizedBox(width: 380, child: const MobileSearchScopeSummary());

/// Live single-select holder so the segmented thumb and the narrow fallback
/// react to taps the way `onChanged` reporting does in the tests.
class _FilterSelectDemo extends StatefulWidget {
  const _FilterSelectDemo({
    required this.filter,
    this.initialSelected = const [],
    this.width = 420,
  });

  final SelectFilter filter;
  final List<String> initialSelected;
  final double width;

  @override
  State<_FilterSelectDemo> createState() => _FilterSelectDemoState();
}

class _FilterSelectDemoState extends State<_FilterSelectDemo> {
  late List<String> _selected = [...widget.initialSelected];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: FilterSelectField(
        filter: widget.filter,
        selected: _selected,
        onChanged: (optionKey) => setState(() {
          _selected = optionKey.isEmpty ? <String>[] : <String>[optionKey];
        }),
      ),
    );
  }
}

/// Live multi-select holder: taps report their key and move the pills.
class _FilterMultiSelectDemo extends StatefulWidget {
  const _FilterMultiSelectDemo({
    required this.options,
    this.initialSelected = const [],
  });

  final List<ExtensionFilterOptionEntry> options;
  final List<String> initialSelected;

  @override
  State<_FilterMultiSelectDemo> createState() => _FilterMultiSelectDemoState();
}

class _FilterMultiSelectDemoState extends State<_FilterMultiSelectDemo> {
  late List<String> _selected = [...widget.initialSelected];

  @override
  Widget build(BuildContext context) {
    return FilterMultiSelectField(
      options: widget.options,
      selected: _selected,
      onToggle: (optionKey) => setState(() {
        _selected = _selected.contains(optionKey)
            ? _selected.where((e) => e != optionKey).toList()
            : [..._selected, optionKey];
      }),
    );
  }
}
