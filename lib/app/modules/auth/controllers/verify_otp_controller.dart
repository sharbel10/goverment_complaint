// modules/auth/controllers/verify_otp_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:goverment_complaints/app/modules/auth/models/request/otp_request_model.dart';
import 'package:goverment_complaints/app/modules/auth/models/response/otp_response_model.dart';
import '../../../services/api_service.dart';

class VerifyOtpController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  var isLoading = false.obs;

  Future<VerifyOtpResponse?> verifyOtp(VerifyOtpRequest req) async {
    isLoading.value = true;
    try {
      final response = await _api.post('verify-otp', data: req.toJson());

      final body = response.data;
      final verifyResp = VerifyOtpResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      final token = verifyResp.data?.token;
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'auth_token', value: token);

        _api.setAuthToken(token);
      }

      final citizen = verifyResp.data?.citizen;
      if (citizen != null) {
        await _secureStorage.write(
          key: 'citizen',
          value: jsonEncode(citizen.toJson()),
        );
      }

      return verifyResp;
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
