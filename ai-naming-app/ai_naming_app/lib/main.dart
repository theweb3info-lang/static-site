import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/app.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化本地存储
  await GetStorage.init();
  
  // 注册全局服务
  Get.put(ApiService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  
  runApp(const AINameApp());
}

class AINameApp extends StatelessWidget {
  const AINameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'AI智能取名',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const AppWrapper(),
        );
      },
    );
  }
}