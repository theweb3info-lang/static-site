import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/home_page.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SeatPlanApp()));
}

class SeatPlanApp extends StatelessWidget {
  const SeatPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeatPlan AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
