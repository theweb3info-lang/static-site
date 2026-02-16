import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/home_page.dart';
import 'shared/theme/app_theme.dart';
import 'shared/utils/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SocialBatteryApp()));
}

class SocialBatteryApp extends ConsumerWidget {
  const SocialBatteryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);

    return MaterialApp(
      title: '社交电量',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
    );
  }
}
