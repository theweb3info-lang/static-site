import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/guests/view/guest_list_page.dart';
import '../features/constraints/view/constraint_page.dart';
import '../features/settings/view/settings_page.dart';
import '../features/seating/view/seating_page.dart';
import '../features/export/view/export_page.dart';
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    GuestListPage(),
    ConstraintPage(),
    SettingsPage(),
    SeatingPage(),
    ExportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: '宾客'),
          NavigationDestination(icon: Icon(Icons.link_outlined), selectedIcon: Icon(Icons.link), label: '约束'),
          NavigationDestination(icon: Icon(Icons.table_restaurant_outlined), selectedIcon: Icon(Icons.table_restaurant), label: '桌位'),
          NavigationDestination(icon: Icon(Icons.auto_fix_high_outlined), selectedIcon: Icon(Icons.auto_fix_high), label: '排座'),
          NavigationDestination(icon: Icon(Icons.share_outlined), selectedIcon: Icon(Icons.share), label: '导出'),
        ],
      ),
    );
  }
}
