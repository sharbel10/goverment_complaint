import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'network_service.dart';

class ApiService {
  late Dio _dio;
  final NetworkService _network = Get.find<NetworkService>();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://example.com/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          Get.snackbar("Error", "Server error");
          return handler.next(e);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    return null;
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    if (!await _network.hasConnection()) {
      Get.snackbar("No Internet", "Please check your network connection");
      return null; // أو throw exception
    }

    final response = await _dio.post(path, data: data);
    return response.data;
  }

  Future<dynamic> get(String path) async {
    if (!await _network.hasConnection()) {
      Get.snackbar("No Internet", "Please check your network connection");
      return null;
    }

    final response = await _dio.get(path);
    return response.data;
  }
}
