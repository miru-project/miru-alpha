import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/pages/detail/detail_loading_page.dart';
import 'package:miru_app_new/pages/home/library_page.dart';
import 'package:miru_app_new/pages/license/license_page.dart';
import 'package:miru_app_new/pages/watch/load_entry.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/index.dart';
import '../../../pages/anilist_webview.dart';
import '../../../pages/download_page.dart';
import '../../pages/favorite/favorite_page_desktop_layout.dart';
import '../../pages/history/history_page.dart';
import '../../../pages/index.dart';
import '../../../pages/main_page.dart';
import '../../pages/webview/mobile_webview.dart';
import '../../pages/search/search_page_single_view.dart';
import '../../model/setting_items.dart';

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

  static Route<void> createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: Curves.ease));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GoRoute _buildDetail = GoRoute(
    path: 'detail',

    builder: (context, state) {
      final extra = ParamCache.getDetailParam(state.extra as DetailParam);
      return DetailLoadingPage(meta: extra.meta, url: extra.url);
    },
  );
  static final appRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/license', builder: (context, state) => MiruLicensePage()),
      GoRoute(
        path: '/watch',
        builder: (context, state) {
          final extra = state.extra! as WatchParams;
          return WatchLoadEntry(param: extra);
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
          return MobileWebViewPage(extMeta: extra.meta, path: extra.url);
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
                pageBuilder: (context, state) => getPage(
                  state: state,
                  child: PlatformWidget(
                    mobileWidget: MiruMobileShellScaffold(),
                    desktopWidget: DesktopLibraryPage(),
                  ),
                ),
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
                    pageBuilder: (context, state) {
                      final extra = state.extra as SearchPageParam;
                      return getPage(
                        state: state,
                        child: SearchPageSingleView(
                          query: extra.query,
                          meta: extra.meta,
                        ),
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
