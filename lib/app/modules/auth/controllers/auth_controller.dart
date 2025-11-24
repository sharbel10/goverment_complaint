import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../models/request/login/login_request_model.dart';
import '../models/response/user_model.dart';


class AuthController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final formKey = GlobalKey<FormState>();
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final user = Rxn<UserModel>();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final request = LoginRequest(
        email: email.value.trim(),
        password: password.value,
      );

      final data = await _api.post(
        '/login',
        data: request.toJson(),
      );

      final userJson = data['user'];
      final token = data['token'];

      user.value = UserModel.fromJson({
        ...userJson,
        'token': token,
      });

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar('Error', 'Login failed');
    } finally {
      isLoading.value = false;
    }
  }
}
