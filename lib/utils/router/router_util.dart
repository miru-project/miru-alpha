import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/pages/detail/detail_loading_page.dart';
import 'package:miru_alpha/pages/download/download_page.dart';
import 'package:miru_alpha/pages/extension_settings/extension_settings.dart';
import 'package:miru_alpha/pages/home/library_page.dart';
import 'package:miru_alpha/pages/license/license_page.dart';
import 'package:miru_alpha/pages/source_code/source_code_page.dart';
import 'package:miru_alpha/pages/watch/load_entry.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:miru_alpha/pages/favorite/favorite_page_layout.dart';
import 'package:miru_alpha/pages/history/history_page.dart';
import 'package:miru_alpha/pages/index.dart';
import 'package:miru_alpha/pages/main_page.dart';
import 'package:miru_alpha/pages/tracking/anilist_search_page.dart';
import 'package:miru_alpha/pages/tracking/anilist_progress_page.dart';
import 'package:miru_alpha/pages/webview/mobile_webview.dart';
import 'package:miru_alpha/pages/search/search_page_single_view.dart';
import 'package:miru_alpha/model/setting_items.dart';
import 'package:miru_alpha/pages/tracking/tracking_page.dart';
import 'package:miru_alpha/pages/dev_tool/dev_tool_page.dart';

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
  static Page noTransitionPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
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
  static final rootKey = GlobalKey<NavigatorState>();
  static final GoRoute _buildDetail = GoRoute(
    path: 'detail',

    builder: (context, state) {
      final extra = ParamCache.getDetailParam(state.extra as DetailParam);
      return DetailLoadingPage(meta: extra.meta, detailUrl: extra.url);
    },
  );
  static final appRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/license', builder: (context, state) => MiruLicensePage()),
      GoRoute(path: '/devTool', builder: (context, state) => const DevToolPage()),
      GoRoute(
        path: '/watch',
        builder: (context, state) {
          final extra = state.extra! as WatchParams;
          return WatchLoadEntry(param: extra);
        },
      ),
      GoRoute(
        path: '/mobileWebView',
        builder: (context, state) {
          final extra = state.extra as WebviewParam;
          return MobileWebViewPage(extMeta: extra.meta, path: extra.url);
        },
      ),
      GoRoute(
        path: '/sourceCode',
        pageBuilder: (context, state) {
          final extra = state.extra as String;
          return noTransitionPage(
            state: state,
            child: SourceCodePage(path: extra),
          );
        },
      ),
      GoRoute(
        path: '/anilistSearch',
        builder: (context, state) {
          final extra = state.extra as AnilistSearchParam;
          return AnilistSearchPage(param: extra);
        },
      ),
      GoRoute(
        path: '/anilistProgress',
        builder: (context, state) {
          final extra = state.extra as AnilistProgressParam;
          return AnilistProgressPage(param: extra);
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
                    pageBuilder: (context, state) => noTransitionPage(
                      state: state,
                      child: const HistoryPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'favorite',
                    pageBuilder: (context, state) => noTransitionPage(
                      state: state,
                      child: const FavoritePage(),
                    ),
                  ),
                  GoRoute(
                    path: 'download',
                    pageBuilder: (context, state) =>
                        noTransitionPage(state: state, child: DownloadPage()),
                  ),
                ],
                path: '/home',
                pageBuilder: (context, state) => noTransitionPage(
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
                pageBuilder: (context, state) => noTransitionPage(
                  state: state,
                  child: SearchPage(search: state.extra as String?),
                ),
                routes: [
                  GoRoute(
                    path: 'single',
                    pageBuilder: (context, state) {
                      final extra = state.extra as SearchPageParam;
                      return noTransitionPage(
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
                pageBuilder: (context, state) => noTransitionPage(
                  state: state,
                  child: const ExtensionPage(),
                ),
              ),
              GoRoute(
                path: '/tracking',
                pageBuilder: (context, state) =>
                    noTransitionPage(state: state, child: const TrackingPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              for (final item in SideBarName.values)
                GoRoute(
                  path: "/settings/${item.name}",
                  pageBuilder: (context, state) => noTransitionPage(
                    state: state,
                    child: SettingPage(selected: item),
                  ),
                ),
              GoRoute(
                path: "/extensionSettings",
                pageBuilder: (context, state) {
                  final param = state.extra as ExtensionSettingParam;
                  return noTransitionPage(
                    state: state,
                    child: ExtensionSettingPage(
                      pkg: param.pkg,
                      name: param.name,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
        pageBuilder: (context, state, navigationShell) {
          if (DeviceUtil.isMobileLayout(context) &&
              (state.fullPath?.split('/') ?? []).length > 2 &&
              state.fullPath?.contains('settings') == false) {
            return noTransitionPage(state: state, child: navigationShell);
          }
          return noTransitionPage(
            state: state,
            child: MainPage(child: navigationShell),
          );
        },
      ),
    ],
  );
}
