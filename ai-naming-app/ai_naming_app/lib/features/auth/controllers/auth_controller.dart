import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  // 代理AuthService的状态
  bool get isLoading => _authService.isLoading.value;
  bool get isAuthenticated => _authService.isAuthenticated.value;
  Map<String, dynamic>? get currentUser => _authService.currentUser.value;

  @override
  void onInit() {
    super.onInit();
    // 监听认证状态变化
    ever(_authService.isLoading, (bool loading) {
      update();
    });
    
    ever(_authService.isAuthenticated, (bool authenticated) {
      update();
    });
  }

  /// 匿名登录
  Future<void> loginAnonymously() async {
    await _authService.loginAnonymously();
  }

  /// 登出
  Future<void> logout() async {
    await _authService.logout();
  }
}