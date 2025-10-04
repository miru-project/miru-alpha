import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import '../../../pages/anilist_webview.dart';
import '../../../pages/download_page.dart';
import '../../../pages/home/favorite_page_desktop_layout.dart';
import '../../../pages/home/history_page.dart';
import '../../../pages/index.dart';
import '../../../pages/main_page.dart';
import '../../pages/watch/manga_reader.dart';
import '../../../pages/mobile_webview.dart';
import '../../pages/watch/novel_reader.dart';
import '../../../pages/search_page_single_view.dart';
import '../../pages/watch/video_player.dart';
import '../../../pages/setting/setting_items.dart';

class ParamCache {
  static DetailParam? detailParam;

  static DetailParam getDetailParam(DetailParam? param) {
    if (param != null) {
      detailParam = param;
      return param;
    }
    if (detailParam == null) {
      throw Exception('DetailParam is null');
    }
    return detailParam!;
  }
}

class RouterUtil {
  static Page getPage({required Widget child, required GoRouterState state}) {
    return MaterialPage(key: state.pageKey, child: child);
  }

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GoRoute _buildDetail = GoRoute(
    path: 'detail',

    builder: (context, state) {
      final extra = ParamCache.getDetailParam(state.extra as DetailParam);
      // throw Exception('DetailParam is null');
      return DetailPage(meta: extra.meta, url: extra.url);
    },
  );
  static final appRouter = GoRouter(
    // observers: [GoRouterObserver()],
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/watch',
        builder: (context, state) {
          final extra = state.extra! as WatchParams;
          switch (extra.type) {
            case ExtensionType.bangumi:
              return MiruVideoPlayer(
                name: extra.name,
                detailImageUrl: extra.detailImageUrl,
                selectedEpisodeIndex: extra.selectedEpisodeIndex,
                selectedGroupIndex: extra.selectedGroupIndex,
                meta: extra.meta,
                detailUrl: extra.detailUrl,
                epGroup: extra.epGroup,
              );
            case ExtensionType.manga:
              return MiruMangaReader(
                name: extra.name,
                detailImageUrl: extra.detailImageUrl,
                selectedEpisodeIndex: extra.selectedEpisodeIndex,
                selectedGroupIndex: extra.selectedGroupIndex,
                meta: extra.meta,
                detailUrl: extra.detailUrl,
                epGroup: extra.epGroup,
              );
            default:
              return MiruNovelReader(
                name: extra.name,
                detailImageUrl: extra.detailImageUrl,
                selectedEpisodeIndex: extra.selectedEpisodeIndex,
                selectedGroupIndex: extra.selectedGroupIndex,
                meta: extra.meta,
                detailUrl: extra.detailUrl,
                epGroup: extra.epGroup,
              );
          }
        },
      ),
      GoRoute(
        path: '/anilist',
        builder: (context, state) {
          return AnilistWebViewPage(url: state.extra as String);
        },
      ),
      GoRoute(
        path: '/mobileWebView',
        builder: (context, state) {
          final extra = state.extra as WebviewParam;
          return WebViewPage(extensionRuntime: extra.meta, url: extra.url);
        },
      ),
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                routes: [
                  GoRoute(
                    path: 'history',
                    pageBuilder: (context, state) =>
                        getPage(state: state, child: const HistoryPage()),
                  ),
                  GoRoute(
                    path: 'favorite',
                    pageBuilder: (context, state) =>
                        getPage(state: state, child: const FavoritePage()),
                  ),
                  GoRoute(
                    path: 'download',
                    pageBuilder: (context, state) =>
                        getPage(state: state, child: DownloadPage()),
                  ),
                ],
                path: '/home',
                pageBuilder: (context, state) =>
                    getPage(state: state, child: FavoritePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) => getPage(
                  state: state,
                  child: SearchPage(search: state.extra as String?),
                ),
                routes: [
                  GoRoute(
                    path: 'single',
                    builder: (context, state) {
                      final extra = state.extra as SearchPageParam;
                      return SearchPageSingleView(
                        query: extra.query,
                        meta: extra.meta,
                      );
                    },
                    routes: [_buildDetail],
                  ),
                  GoRoute(
                    path: 'globalSearch',
                    routes: [_buildDetail],
                    builder: (context, state) {
                      final extra = state.extra as SearchPageParam;
                      return SearchPageSingleView(
                        query: extra.query,
                        meta: extra.meta,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/extension',
                pageBuilder: (context, state) =>
                    getPage(state: state, child: const ExtensionPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              for (final item in SideBarName.values)
                GoRoute(
                  path: "/settings/${item.name}",
                  pageBuilder: (context, state) => getPage(
                    state: state,
                    child: SettingPage(selected: item),
                  ),
                ),
            ],
          ),
        ],
        pageBuilder: (context, state, navigationShell) => getPage(
          state: state,
          child: MainPage(child: navigationShell),
        ),
      ),
    ],
  );
}

class SearchPageParam {
  final String? query;
  final ExtensionMeta meta;
  const SearchPageParam({this.query, required this.meta});
}

class WebviewParam {
  final ExtensionMeta meta;
  final String url;
  const WebviewParam({required this.meta, required this.url});
}
