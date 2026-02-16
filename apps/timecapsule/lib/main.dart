import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/view/home_page.dart';
import 'features/capsule/service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: TimeCapsuleApp()));
}

class TimeCapsuleApp extends StatelessWidget {
  const TimeCapsuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时间胶囊',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
