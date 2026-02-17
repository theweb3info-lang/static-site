import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/bazi_analysis.dart';
import '../../../core/models/name_result.dart';
import '../views/naming_input_page.dart';

class NamingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();
  
  // 响应式状态
  var isLoading = false.obs;
  var currentStep = 1.obs; // 1: 输入信息, 2: 八字分析, 3: 名字推荐
  
  // 用户输入数据
  var surname = ''.obs;
  var gender = '男'.obs;
  var birthDate = DateTime.now().obs;
  var birthHour = 12.obs;
  
  // 计算结果
  Rx<BaziAnalysis?> baziAnalysis = Rx<BaziAnalysis?>(null);
  RxList<NameResult> nameResults = <NameResult>[].obs;
  RxList<NameResult> favoriteNames = <NameResult>[].obs;
  
  // 付费状态
  var isPaidUser = false.obs;
  var hasGeneratedFreeNames = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFavoriteNames();
    _checkPaidStatus();
  }

  /// 开始取名流程
  void startNaming() {
    currentStep.value = 1;
    Get.to(() => const NamingInputPage());
  }

  /// 计算八字分析
  Future<void> calculateBazi() async {
    if (!_validateInput()) return;

    try {
      isLoading.value = true;
      
      final result = await _apiService.calculateBazi(
        surname: surname.value,
        gender: gender.value,
        birthDate: birthDate.value,
        hour: birthHour.value,
      );
      
      baziAnalysis.value = result;
      currentStep.value = 2;
      
      Get.snackbar(
        '计算完成',
        '八字分析已完成，请查看结果',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      
    } catch (e) {
      Get.snackbar(
        '计算失败',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 生成免费名字（3个）
  Future<void> generateFreeNames() async {
    if (baziAnalysis.value == null) {
      Get.snackbar('错误', '请先完成八字分析');
      return;
    }

    if (hasGeneratedFreeNames.value) {
      Get.snackbar('提示', '今日免费次数已用完，请购买完整版');
      return;
    }

    try {
      isLoading.value = true;
      
      final results = await _apiService.generateNames(
        surname: surname.value,
        gender: gender.value,
        baziAnalysis: baziAnalysis.value!.toJson(),
        isPaid: false,
      );
      
      nameResults.assignAll(results);
      hasGeneratedFreeNames.value = true;
      currentStep.value = 3;
      
      // 保存免费使用记录
      _storage.write('last_free_use_date', DateTime.now().toIso8601String());
      
    } catch (e) {
      Get.snackbar('生成失败', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 购买完整版服务
  Future<void> purchaseFullVersion() async {
    try {
      isLoading.value = true;
      
      // 创建支付订单
      final orderData = await _apiService.createPaymentOrder(
        amount: 1999, // 19.99元
        productName: '专业取名服务',
        description: '50个精选名字 + 详细分析报告',
      );
      
      // TODO: 调用微信支付
      // 这里应该集成fluwx进行实际支付
      
      // 模拟支付成功
      await Future.delayed(const Duration(seconds: 2));
      
      isPaidUser.value = true;
      _storage.write('is_paid_user', true);
      
      await generatePaidNames();
      
      Get.snackbar(
        '购买成功',
        '感谢您的支持！已解锁完整版功能',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      
    } catch (e) {
      Get.snackbar('购买失败', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 生成付费名字（50个）
  Future<void> generatePaidNames() async {
    try {
      isLoading.value = true;
      
      final results = await _apiService.generateNames(
        surname: surname.value,
        gender: gender.value,
        baziAnalysis: baziAnalysis.value!.toJson(),
        isPaid: true,
      );
      
      nameResults.assignAll(results);
      
    } catch (e) {
      Get.snackbar('生成失败', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 收藏/取消收藏名字
  void toggleFavorite(NameResult name) {
    if (favoriteNames.any((n) => n.name == name.name)) {
      favoriteNames.removeWhere((n) => n.name == name.name);
      Get.snackbar('已取消', '已取消收藏 ${name.name}');
    } else {
      favoriteNames.add(name);
      Get.snackbar('已收藏', '已收藏 ${name.name}');
    }
    
    _saveFavoriteNames();
  }

  /// 检查是否已收藏
  bool isFavorite(NameResult name) {
    return favoriteNames.any((n) => n.name == name.name);
  }

  /// 重新开始取名
  void restart() {
    currentStep.value = 1;
    surname.value = '';
    gender.value = '男';
    birthDate.value = DateTime.now();
    birthHour.value = 12;
    baziAnalysis.value = null;
    nameResults.clear();
    hasGeneratedFreeNames.value = _checkTodayFreeUse();
  }

  /// 获取名字详细分析
  Future<NameResult> getNameDetail(String name) async {
    if (baziAnalysis.value == null) {
      throw Exception('缺少八字分析数据');
    }

    try {
      return await _apiService.getNameDetail(
        name: name,
        baziAnalysis: baziAnalysis.value!.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 验证输入
  bool _validateInput() {
    if (surname.isEmpty) {
      Get.snackbar('提示', '请输入姓氏');
      return false;
    }
    
    if (surname.value.length > 2) {
      Get.snackbar('提示', '姓氏不能超过2个字');
      return false;
    }
    
    if (birthDate.value.isAfter(DateTime.now())) {
      Get.snackbar('提示', '出生日期不能晚于今天');
      return false;
    }
    
    return true;
  }

  /// 检查付费状态
  void _checkPaidStatus() {
    isPaidUser.value = _storage.read('is_paid_user') ?? false;
    hasGeneratedFreeNames.value = _checkTodayFreeUse();
  }

  /// 检查今日是否已使用免费次数
  bool _checkTodayFreeUse() {
    final lastUseDate = _storage.read('last_free_use_date');
    if (lastUseDate == null) return false;
    
    final lastUse = DateTime.parse(lastUseDate);
    final today = DateTime.now();
    
    return lastUse.year == today.year &&
           lastUse.month == today.month &&
           lastUse.day == today.day;
  }

  /// 加载收藏的名字
  void _loadFavoriteNames() {
    final favoriteData = _storage.read('favorite_names');
    if (favoriteData != null) {
      try {
        final List<dynamic> favoriteList = favoriteData;
        favoriteNames.assignAll(
          favoriteList.map((json) => NameResult.fromJson(json)).toList(),
        );
      } catch (e) {
        print('加载收藏名字失败: $e');
      }
    }
  }

  /// 保存收藏的名字
  void _saveFavoriteNames() {
    final favoriteData = favoriteNames.map((name) => name.toJson()).toList();
    _storage.write('favorite_names', favoriteData);
  }

  /// 获取时辰选项
  List<Map<String, dynamic>> get hourOptions {
    return [
      {'value': 0, 'text': '子时 (23:00-00:59)'},
      {'value': 1, 'text': '丑时 (01:00-02:59)'},
      {'value': 3, 'text': '寅时 (03:00-04:59)'},
      {'value': 5, 'text': '卯时 (05:00-06:59)'},
      {'value': 7, 'text': '辰时 (07:00-08:59)'},
      {'value': 9, 'text': '巳时 (09:00-10:59)'},
      {'value': 11, 'text': '午时 (11:00-12:59)'},
      {'value': 13, 'text': '未时 (13:00-14:59)'},
      {'value': 15, 'text': '申时 (15:00-16:59)'},
      {'value': 17, 'text': '酉时 (17:00-18:59)'},
      {'value': 19, 'text': '戌时 (19:00-20:59)'},
      {'value': 21, 'text': '亥时 (21:00-22:59)'},
    ];
  }

  /// 获取当前步骤描述
  String get currentStepDescription {
    switch (currentStep.value) {
      case 1:
        return '请输入宝宝的基本信息';
      case 2:
        return '八字分析完成，查看五行情况';
      case 3:
        return '名字推荐完成，选择心仪的名字';
      default:
        return '';
    }
  }
}