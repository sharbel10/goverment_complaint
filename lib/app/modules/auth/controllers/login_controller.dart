import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:goverment_complaints/app/modules/auth/models/request/login_request_model.dart';
import 'package:goverment_complaints/app/modules/auth/models/response/login_response_model.dart';
import '../../../services/api_service.dart';

class LoginController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;

  Future<LoginResponse?> login() async {
    if (!formKey.currentState!.validate()) return null;
    final req = LoginRequest(
      email: email.text.trim(),
      password: password.text.trim(),
    );
    isLoading.value = true;
    try {
      final response = await _api.post('login', data: req.toJson());
      final body = response.data;
      final loginResp = LoginResponse.fromJson(Map<String, dynamic>.from(body));

      final token = loginResp.data?.token;
      final citizen = loginResp.data?.citizen;
      final citizenId = citizen?.id;

      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'auth_token', value: token);
        _api.setAuthToken(token);
      }

      if (citizenId != null) {
        await _secureStorage.write(
          key: 'citizen_id',
          value: citizenId.toString(),
        );
      }

      return loginResp;
    } on ApiException catch (e) {
      Get.snackbar(
        'خطأ',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'خطأ غير متوقع',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getSavedToken() => _secureStorage.read(key: 'auth_token');
}
