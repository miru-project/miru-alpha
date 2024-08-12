import 'package:go_router/go_router.dart';
import 'package:miru_app_new/views/pages/index.dart';

class RouterUtil {
  static final appRouter = GoRouter(routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/detail', // Define the path with a parameter
      builder: (context, state) {
        final extra =
            state.extra! as Map<String, dynamic>; // Extract the parameter
        return DetailPage(
            extensionService: extra['service'],
            url: extra['url']); // Pass the parameter to the DetailPage
      },
    ),
    GoRoute(
        path: '/extension', builder: (context, state) => const ExtensionPage()),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsPage()),
  ]);
}
