import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../models/bazi_analysis.dart';
import '../models/name_result.dart';

class ApiService extends GetxService {
  late Dio _dio;
  static const String baseUrl = 'https://your-api-domain.com/api/v1';
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.read('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));

    // 添加日志拦截器（仅在调试模式）
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
    ));
  }

  /// 计算八字分析
  Future<BaziAnalysis> calculateBazi({
    required String surname,
    required String gender,
    required DateTime birthDate,
    required int hour,
    double longitude = 116.4074,
  }) async {
    try {
      final response = await _dio.post('/bazi/calculate', data: {
        'surname': surname,
        'gender': gender,
        'year': birthDate.year,
        'month': birthDate.month,
        'day': birthDate.day,
        'hour': hour,
        'longitude': longitude,
      });

      return BaziAnalysis.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 生成名字推荐
  Future<List<NameResult>> generateNames({
    required String surname,
    required String gender,
    required Map<String, dynamic> baziAnalysis,
    required bool isPaid,
  }) async {
    try {
      final response = await _dio.post('/names/generate', data: {
        'surname': surname,
        'gender': gender,
        'bazi_analysis': baziAnalysis,
        'is_paid': isPaid,
      });

      return (response.data['names'] as List)
          .map((json) => NameResult.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取名字详细分析
  Future<NameResult> getNameDetail({
    required String name,
    required Map<String, dynamic> baziAnalysis,
  }) async {
    try {
      final response = await _dio.post('/names/detail', data: {
        'name': name,
        'bazi_analysis': baziAnalysis,
      });

      return NameResult.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 创建支付订单
  Future<Map<String, dynamic>> createPaymentOrder({
    required int amount,
    required String productName,
    required String description,
  }) async {
    try {
      final response = await _dio.post('/payment/create-order', data: {
        'amount': amount,
        'product_name': productName,
        'description': description,
      });

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  void _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '网络连接超时，请检查网络设置';
        break;
      case DioExceptionType.badResponse:
        message = _getErrorMessage(error.response);
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      default:
        message = '网络错误，请稍后重试';
    }
    
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
    );
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请重试';
      case DioExceptionType.badResponse:
        return _getErrorMessage(e.response);
      default:
        return '网络错误，请重试';
    }
  }

  String _getErrorMessage(Response? response) {
    if (response?.data is Map) {
      return response?.data['message'] ?? response?.data['detail'] ?? '服务器错误';
    }
    return '服务器错误(${response?.statusCode})';
  }
}