import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/activities/view/add_activity_page.dart';
import '../features/calendar/view/calendar_page.dart';
import '../features/dashboard/view/dashboard_page.dart';
import '../features/excuses/view/excuses_page.dart';
import '../features/report/view/report_page.dart';
import '../features/topics/view/topics_page.dart';
import '../shared/theme/app_theme.dart';
import '../shared/utils/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _titles = ['社交电量', '社交日历', '话题卡片', '退场借口', '周报'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    final isDark = ref.watch(themeModeProvider);

    final pages = [
      const DashboardPage(),
      const CalendarPage(),
      const TopicsPage(),
      const ExcusesPage(),
      const ReportPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentTab]),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
            tooltip: isDark ? '切换到浅色模式' : '切换到深色模式',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[currentTab],
      ),
      floatingActionButton: currentTab == 0 || currentTab == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddActivityPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.battery_std_outlined),
            selectedIcon: Icon(Icons.battery_std),
            label: '电量',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: '日历',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '话题',
          ),
          NavigationDestination(
            icon: Icon(Icons.exit_to_app_outlined),
            selectedIcon: Icon(Icons.exit_to_app),
            label: '借口',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '周报',
          ),
        ],
      ),
    );
  }
}
