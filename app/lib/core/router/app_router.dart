import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/application/presentation/screens/application_history_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/cv_profile/presentation/screens/cv_profile_editor_screen.dart';
import '../../features/job_search/presentation/screens/job_detail_screen.dart';
import '../../features/job_search/presentation/screens/job_search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// Bridges Riverpod's [authNotifierProvider] to a [Listenable] so GoRouter's
/// `refreshListenable` re-evaluates `redirect` whenever auth state changes,
/// without rebuilding the whole router (which would lose navigation state).
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authNotifierProvider, (_, _) => notifyListeners());
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(this.assetPath);

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: 39,
      height: 39,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.circle_outlined),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: [
          const NavigationDestination(
            icon: _NavIcon('assets/icons/icon_jobs_briefcase.png'),
            label: 'Jobs',
          ),
          const NavigationDestination(
            icon: _NavIcon('assets/icons/icon_cv.png'),
            label: 'CV',
          ),
          const NavigationDestination(
            icon: _NavIcon('assets/icons/icon_unassigned_spiral.png'),
            label: 'Verlauf',
          ),
          const NavigationDestination(
            icon: _NavIcon('assets/icons/icon_settings.png'),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/jobs',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState is AuthUnknown) return null;
      if (authState is AuthLoggedOut) return isAuthRoute ? null : '/login';
      if (authState is AuthLoggedIn && isAuthRoute) return '/jobs';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const JobSearchScreen(),
                routes: [
                  GoRoute(
                    path: ':source/:id',
                    builder: (context, state) => JobDetailScreen(
                      source: state.pathParameters['source']!,
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cv',
                builder: (context, state) => const CvProfileEditorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const ApplicationHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
