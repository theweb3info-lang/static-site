import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/splash_page.dart';
import '../features/naming/views/home_page.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) {
        if (controller.isLoading.value) {
          return const SplashPage();
        }
        
        return const HomePage();
      },
    );
  }
}