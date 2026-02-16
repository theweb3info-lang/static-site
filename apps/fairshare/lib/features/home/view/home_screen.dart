import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../chores/view/chores_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../chores/view/history_screen.dart';
import '../../members/view/members_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    ChoresScreen(),
    DashboardScreen(),
    HistoryScreen(),
    MembersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: '打卡'),
          NavigationDestination(icon: Icon(Icons.pie_chart_rounded), label: '仪表盘'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: '记录'),
          NavigationDestination(icon: Icon(Icons.people_rounded), label: '成员'),
        ],
      ),
    );
  }
}
