import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/views/pages/index.dart';
import 'package:miru_app_new/views/pages/main_page.dart';

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
              pageBuilder: (context, state) =>
                  getPage(state: state, child: const SearchPage()),
              routes: [
                GoRoute(
                  path: 'detail', // Define the path with a parameter
                  builder: (context, state) {
                    final extra = state.extra!
                        as Map<String, dynamic>; // Extract the parameter
                    return DetailPage(
                        extensionService: extra['service'],
                        url: extra[
                            'url']); // Pass the parameter to the DetailPage
                  },
                ),
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
