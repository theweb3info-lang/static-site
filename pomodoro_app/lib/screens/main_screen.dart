import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../providers/timer_provider.dart';
import 'timer_screen.dart';
import 'tasks_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: _selectedIndex,
            onChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.timer),
                label: Text('Timer'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.list_bullet),
                label: Text('Tasks'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.chart_bar),
                label: Text('Statistics'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.settings),
                label: Text('Settings'),
              ),
            ],
          );
        },
        top: _buildSidebarHeader(context),
        bottom: _buildSidebarFooter(context),
      ),
      child: IndexedStack(
        index: _selectedIndex,
        children: const [
          TimerScreen(),
          TasksScreen(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '🍅',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Pomodoro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MacosTheme.of(context).canvasColor.withValues(alpha: 0.5),
            border: Border(
              top: BorderSide(
                color: MacosTheme.of(context).dividerColor,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timer.formattedTime,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timer.sessionTypeLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: MacosTheme.of(context).typography.caption1.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
