import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/views/pages/anilist_webview.dart';
import 'package:miru_app_new/views/pages/index.dart';
import 'package:miru_app_new/views/pages/main_page.dart';
import 'package:miru_app_new/views/pages/manga_reader.dart';
import 'package:miru_app_new/views/pages/mobile_webview.dart';
import 'package:miru_app_new/views/pages/novel_reader.dart';
import 'package:miru_app_new/views/pages/search_page_single_view.dart';
import 'package:miru_app_new/views/pages/video_player.dart';

class RouterUtil {
  static Page getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
    );
  }

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();
  static final appRouter = GoRouter(navigatorKey: rootNavigatorKey, routes: [
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
        }),
    GoRoute(
        path: '/mobileWebView',
        builder: (context, state) {
          final extra = state.extra as WebviewParam;
          return WebViewPage(extensionRuntime: extra.service, url: extra.url);
        }),
    StatefulShellRoute.indexedStack(
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/',
              pageBuilder: (context, state) =>
                  getPage(state: state, child: const HomePage())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/search',
              pageBuilder: (context, state) => getPage(
                  state: state,
                  child: SearchPage(
                    search: state.extra as String?,
                  )),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final extra = state.extra as DetailParam;
                    return DetailPage(
                      extensionService: extra.service,
                      url: extra.url,
                    );
                  },
                ),
                GoRoute(
                    path: 'single',
                    builder: (context, state) {
                      final extra = state.extra as SearchPageParam;
                      return SearchPageSingleView(
                          query: extra.query, service: extra.service);
                    })
              ])
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/extension',
            pageBuilder: (context, state) =>
                getPage(state: state, child: const ExtensionPage()),
          )
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                getPage(state: state, child: const SettingsPage()),
          )
        ])
      ],
      pageBuilder: (context, state, navigationShell) => getPage(
          state: state,
          child: MainPage(
            child: navigationShell,
          )),
    )
    // ShellRoute(
    //     navigatorKey: shellNavigatorKey,
    //     builder: (context, state, child) => MainPage(
    //           context: context,
    //           state: state,
    //           child: child,
    //         ),
    //     routes: <RouteBase>[
    //       GoRoute(path: '/', builder: (context, state) => const HomePage()),
    //       GoRoute(
    //         path: '/search',
    //         builder: (context, state) => const SearchPage(),
    //       ),
    //       GoRoute(
    //         path: '/detail', // Define the path with a parameter
    //         builder: (context, state) {
    //           final extra =
    //               state.extra! as Map<String, dynamic>; // Extract the parameter
    //           return DetailPage(
    //               extensionService: extra['service'],
    //               url: extra['url']); // Pass the parameter to the DetailPage
    //         },
    //       ),
    //       GoRoute(
    //           path: '/extension',
    //           builder: (context, state) => const ExtensionPage()),
    //       GoRoute(
    //           parentNavigatorKey: shellNavigatorKey,
    //           path: '/settings',
    //           builder: (context, state) => const SettingsPage()),
    //     ])
  ]);
}

class SearchPageParam {
  final String? query;
  final ExtensionApiV1 service;
  const SearchPageParam({this.query, required this.service});
}

class WebviewParam {
  final ExtensionApiV1 service;
  final String url;
  const WebviewParam({required this.service, required this.url});
}
