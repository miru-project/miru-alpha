import 'package:go_router/go_router.dart';
import 'package:miru_app_new/views/pages/index.dart';

class RouterUtil {
  static final appRouter = GoRouter(routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
        routes: [
          GoRoute(
              path: '/detail', builder: (context, state) => const DetailPage())
        ]),
    GoRoute(
        path: '/extension', builder: (context, state) => const ExtensionPage()),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsPage()),
  ]);
}
