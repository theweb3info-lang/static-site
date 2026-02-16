import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/scan/scan_screen.dart';
import '../features/scan/scan_result_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/scan',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => _ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/scan-result',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ScanResultScreen(
          imagePath: extra['imagePath'] as String,
        );
      },
    ),
  ],
);

class _ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const _ScaffoldWithNav({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = switch (location) {
      '/scan' => 0,
      '/profile' => 1,
      '/history' => 2,
      '/settings' => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          final routes = ['/scan', '/profile', '/history', '/settings'];
          context.go(routes[i]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
