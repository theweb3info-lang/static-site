import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final GetStorage _storage = GetStorage();
  
  var isAuthenticated = false.obs;
  var currentUser = Rxn<Map<String, dynamic>>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initAuth();
  }

  Future<void> _initAuth() async {
    // 模拟初始化延迟
    await Future.delayed(const Duration(seconds: 2));
    
    // 检查本地存储的认证信息
    final token = _storage.read('auth_token');
    final userData = _storage.read('user_data');
    
    if (token != null && userData != null) {
      isAuthenticated.value = true;
      currentUser.value = Map<String, dynamic>.from(userData);
    }
    
    isLoading.value = false;
  }

  /// 匿名登录（无需注册即可使用基础功能）
  Future<void> loginAnonymously() async {
    try {
      isLoading.value = true;
      
      // 生成临时用户ID
      final anonymousId = 'anon_${DateTime.now().millisecondsSinceEpoch}';
      
      final userData = {
        'id': anonymousId,
        'name': '游客',
        'isAnonymous': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // 保存到本地存储
      _storage.write('auth_token', 'anonymous_token');
      _storage.write('user_data', userData);
      
      isAuthenticated.value = true;
      currentUser.value = userData;
      
    } finally {
      isLoading.value = false;
    }
  }

  /// 登出
  Future<void> logout() async {
    _storage.remove('auth_token');
    _storage.remove('user_data');
    
    isAuthenticated.value = false;
    currentUser.value = null;
  }

  /// 检查是否为付费用户
  bool get isPaidUser {
    return _storage.read('is_paid_user') ?? false;
  }

  /// 设置付费状态
  void setPaidStatus(bool isPaid) {
    _storage.write('is_paid_user', isPaid);
  }
}