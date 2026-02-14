import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'providers/timer_provider.dart';
import 'providers/task_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/statistics_provider.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'services/tray_service.dart';
import 'services/platform_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  // Initialize services
  await DatabaseService.instance.initialize();
  await NotificationService.instance.initialize();
  await PlatformService.instance.initialize();
  
  // Configure window
  const windowOptions = WindowOptions(
    size: Size(380, 600),
    minimumSize: Size(350, 500),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatefulWidget {
  const PomodoroApp({super.key});

  @override
  State<PomodoroApp> createState() => _PomodoroAppState();
}

class _PomodoroAppState extends State<PomodoroApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    TrayService.instance.initialize();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Hide instead of close to keep tray running
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()..loadStatistics()),
        ChangeNotifierProxyProvider<SettingsProvider, TimerProvider>(
          create: (context) => TimerProvider(
            settings: context.read<SettingsProvider>(),
            statistics: context.read<StatisticsProvider>(),
          ),
          update: (context, settings, previous) => 
            previous ?? TimerProvider(
              settings: settings,
              statistics: context.read<StatisticsProvider>(),
            ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MacosApp(
            title: 'Pomodoro',
            debugShowCheckedModeBanner: false,
            theme: MacosThemeData.light(),
            darkTheme: MacosThemeData.dark(),
            themeMode: settings.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
