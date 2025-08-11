import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/miru_core/extension/extension_service.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/views/pages/anilist_webview.dart';
import 'package:miru_app_new/views/pages/download_page.dart';
import 'package:miru_app_new/views/pages/home/favorite_page_desktop_layout.dart';
import 'package:miru_app_new/views/pages/home/history_page.dart';
import 'package:miru_app_new/views/pages/home/home_page.dart';
import 'package:miru_app_new/views/pages/index.dart';
import 'package:miru_app_new/views/pages/main_page.dart';
import 'package:miru_app_new/views/pages/manga_reader.dart';
import 'package:miru_app_new/views/pages/mobile_webview.dart';
import 'package:miru_app_new/views/pages/novel_reader.dart';
import 'package:miru_app_new/views/pages/search_page_single_view.dart';
import 'package:miru_app_new/views/pages/video_player.dart';

class ParamCache {
  static DetailParam? detailParam;

  static DetailParam? getDetailParam(DetailParam? param) {
    if (param != null) {
      detailParam = param;
      return param;
    }
    return detailParam;
  }
}

class RouterUtil {
  static Page getPage({required Widget child, required GoRouterState state}) {
    return MaterialPage(key: state.pageKey, child: child);
  }

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();
  static final appRouter = GoRouter(
    observers: [GoRouterObserver()],
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
                service: extra.service,
                detailUrl: extra.detailUrl,
                epGroup: extra.epGroup,
              );
            case ExtensionType.manga:
              return MiruMangaReader(
                name: extra.name,
                detailImageUrl: extra.detailImageUrl,
                selectedEpisodeIndex: extra.selectedEpisodeIndex,
                selectedGroupIndex: extra.selectedGroupIndex,
                service: extra.service,
                detailUrl: extra.detailUrl,
                epGroup: extra.epGroup,
              );
            default:
              return MiruNovelReader(
                name: extra.name,
                detailImageUrl: extra.detailImageUrl,
                selectedEpisodeIndex: extra.selectedEpisodeIndex,
                selectedGroupIndex: extra.selectedGroupIndex,
                service: extra.service,
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
          return WebViewPage(extensionRuntime: extra.service, url: extra.url);
        },
      ),
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                routes: [
                  GoRoute(path: 'history', pageBuilder: (context, state) => getPage(state: state, child: const HistoryPage())),
                  GoRoute(path: 'favorite', pageBuilder: (context, state) => getPage(state: state, child: const FavoritePage())),
                  GoRoute(path: 'download', pageBuilder: (context, state) => getPage(state: state, child: DownloadPage())),
                ],
                path: '/home',
                pageBuilder: (context, state) => getPage(state: state, child: const HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) => getPage(state: state, child: SearchPage(search: state.extra as String?)),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final extra = ParamCache.getDetailParam(state.extra as DetailParam?);
                      throw Exception('DetailParam is null');
                      // return DetailPage(extensionService: extra.service, url: extra.url);
                    },
                  ),
                  GoRoute(
                    path: 'single',
                    builder: (context, state) {
                      final extra = state.extra as SearchPageParam;
                      return SearchPageSingleView(query: extra.query, service: extra.service);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/extension', pageBuilder: (context, state) => getPage(state: state, child: const ExtensionPage()))],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/settings', pageBuilder: (context, state) => getPage(state: state, child: const SettingsPage()))],
          ),
        ],
        pageBuilder: (context, state, navigationShell) => getPage(state: state, child: MainPage(child: navigationShell)),
      ),
    ],
  );
}

class SearchPageParam {
  final String? query;
  final ExtensionApi service;
  const SearchPageParam({this.query, required this.service});
}

class WebviewParam {
  final ExtensionApi service;
  final String url;
  const WebviewParam({required this.service, required this.url});
}

class GoRouterObserver extends RouteObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info('MyTest didPush: $route');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info('MyTest didPop: $route');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info('MyTest didRemove: $route');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.info('MyTest didReplace: $newRoute');
  }
}
