import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart' as dio;

import 'package:goverment_complaints/app/modules/auth/models/request/login_request_model.dart';
import 'package:goverment_complaints/app/modules/auth/models/response/login_response_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_snackbar.dart';

class LoginController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;

  void _debugPrintDioResponse(dio.Response response, {required String tag}) {
    try {
      debugPrint('========== $tag RESPONSE ==========');
      debugPrint('$tag -> statusCode: ${response.statusCode}');
      debugPrint('$tag -> statusMessage: ${response.statusMessage}');
      debugPrint('$tag -> headers: ${response.headers.map}');
      debugPrint('$tag -> dataType: ${response.data.runtimeType}');
      debugPrint('$tag -> raw data: ${response.data}');

      if (response.data is Map || response.data is List) {
        debugPrint(
          '$tag -> pretty json:\n'
              '${const JsonEncoder.withIndent("  ").convert(response.data)}',
        );
      }
      debugPrint('==================================');
    } catch (e) {
      debugPrint('$tag -> debug print failed: $e');
    }
  }

  void _snackError(String message) {
    showAppSnack(
      title: 'error'.tr,
      message: message,
      type: AppSnackType.error,
    );
  }


  Future<LoginResponse?> login() async {
    if (!formKey.currentState!.validate()) return null;

    final req = LoginRequest(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    debugPrint('LOGIN -> request body: ${req.toJson()}');

    isLoading.value = true;
    try {
      final dio.Response response = await _api.post('login', data: req.toJson());

      _debugPrintDioResponse(response, tag: 'LOGIN');

      final body = response.data;

      if (body is! Map) {
        debugPrint('LOGIN -> Unexpected response type: ${body.runtimeType}');
        _snackError('Unexpected response type: ${body.runtimeType}');
        return null;
      }

      final loginResp = LoginResponse.fromJson(Map<String, dynamic>.from(body));

      final token = loginResp.data?.token;
      final citizenId = loginResp.data?.citizen?.id;

      debugPrint('LOGIN -> parsed token exists: ${token != null && token.isNotEmpty}');
      debugPrint('LOGIN -> parsed citizenId: $citizenId');

      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'auth_token', value: token);
        _api.setAuthToken(token);
        debugPrint('LOGIN -> token saved + setAuthToken');
      }

      if (citizenId != null) {
        await _secureStorage.write(key: 'citizen_id', value: citizenId.toString());
        debugPrint('LOGIN -> citizen_id saved ');
      }

      return loginResp;
    } on ApiException catch (e, st) {
      debugPrint('LOGIN -> ApiException: ${e.message} (code: ${e.statusCode})');
      debugPrint('LOGIN -> StackTrace: $st');
      _snackError(e.message);
      return null;
    } catch (e, st) {
      debugPrint('LOGIN -> Exception: $e');
      debugPrint('LOGIN -> StackTrace: $st');
      _snackError(e.toString());
      return null;
    } finally {
      isLoading.value = false;
      debugPrint('LOGIN -> isLoading=false');
    }
  }

  Future<String?> getSavedToken() => _secureStorage.read(key: 'auth_token');
}
