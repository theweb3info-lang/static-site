import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../shared/themes/app_theme.dart';
import '../controllers/auth_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final controller = Get.find<AuthController>();
    
    // 等待认证初始化完成
    await Future.delayed(const Duration(seconds: 3));
    
    // 如果未认证，自动匿名登录
    if (!controller.isAuthenticated) {
      await controller.loginAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo区域
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 60.sp,
                color: AppTheme.primaryColor,
              ),
            ),
            
            SizedBox(height: AppSpacing.xl),
            
            // 应用名称
            Text(
              'AI智能取名',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            
            SizedBox(height: AppSpacing.sm),
            
            // 副标题
            Text(
              '结合八字五行 · 传承文化智慧',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 1,
              ),
            ),
            
            SizedBox(height: AppSpacing.xxl),
            
            // 加载指示器
            const SpinKitWave(
              color: Colors.white,
              size: 40,
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            Text(
              '正在初始化...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            
            // 底部装饰
            Positioned(
              bottom: 50.h,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    '让每个宝宝都拥有好名字',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureTag('八字分析'),
                      SizedBox(width: AppSpacing.sm),
                      _buildFeatureTag('AI生成'),
                      SizedBox(width: AppSpacing.sm),
                      _buildFeatureTag('专业评分'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}