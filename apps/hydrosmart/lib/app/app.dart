import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/theme/app_theme.dart';
import '../shared/services/preferences_service.dart';
import '../features/home/view/home_page.dart';
import '../features/settings/view/settings_page.dart';

class HydroSmartApp extends ConsumerWidget {
  const HydroSmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'HydroSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: ref.watch(isOnboardedProvider).when(
            data: (onboarded) =>
                onboarded ? const HomePage() : const SettingsPage(isOnboarding: true),
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (_, __) => const HomePage(),
          ),
    );
  }
}
