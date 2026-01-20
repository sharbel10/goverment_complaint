import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart' as dio;

import 'package:goverment_complaints/app/modules/auth/models/request/otp_request_model.dart';
import 'package:goverment_complaints/app/modules/auth/models/response/otp_response_model.dart';
import '../../../services/api_service.dart';

class VerifyOtpController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var resendLoading = false.obs;

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

  Future<bool> resendOtp(int citizenId) async {
    resendLoading.value = true;
    try {
      debugPrint('RESEND OTP -> sending citizen_id=$citizenId');

      final dio.Response response = await _api.post(
        'resend-otp',
        data: {'citizen_id': citizenId},
      );

      _debugPrintDioResponse(response, tag: 'RESEND_OTP');

      final body = response.data;
      if (body is Map) {
        return body['status'].toString().toLowerCase() == 'success';
      }
      return false;
    } on ApiException catch (e, st) {
      debugPrint('RESEND OTP -> ApiException: ${e.message} (code: ${e.statusCode})');
      debugPrint('RESEND OTP -> StackTrace: $st');
      return false;
    } catch (e, st) {
      debugPrint('RESEND OTP -> Exception: $e');
      debugPrint('RESEND OTP -> StackTrace: $st');
      return false;
    } finally {
      resendLoading.value = false;
    }
  }

  Future<VerifyOtpResponse?> verifyOtp(VerifyOtpRequest req) async {
    isLoading.value = true;
    try {
      debugPrint('VERIFY OTP -> sending: ${req.toJson()}');

      final dio.Response response = await _api.post('verify-otp', data: req.toJson());

      _debugPrintDioResponse(response, tag: 'VERIFY_OTP');

      final body = response.data;
      if (body is! Map) {
        debugPrint('VERIFY OTP -> Unexpected response type: ${body.runtimeType}');
        return null;
      }

      final verifyResp = VerifyOtpResponse.fromJson(Map<String, dynamic>.from(body));

      final token = verifyResp.data?.token;
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'auth_token', value: token);
        _api.setAuthToken(token);
        debugPrint('VERIFY OTP -> token saved + setAuthToken ');
      }

      final citizen = verifyResp.data?.citizen;
      if (citizen != null) {
        await _secureStorage.write(key: 'citizen', value: jsonEncode(citizen.toJson()));
        await _secureStorage.write(key: 'citizen_id', value: citizen.id.toString());
        debugPrint('VERIFY OTP -> citizen saved  id=${citizen.id}');
      }

      return verifyResp;
    } on ApiException catch (e, st) {
      debugPrint('VERIFY OTP -> ApiException: ${e.message} (code: ${e.statusCode})');
      debugPrint('VERIFY OTP -> StackTrace: $st');
      return null;
    } catch (e, st) {
      debugPrint('VERIFY OTP -> Exception: $e');
      debugPrint('VERIFY OTP -> StackTrace: $st');
      return null;
    } finally {
      isLoading.value = false;
      debugPrint('VERIFY OTP -> isLoading=false');
    }
  }

  Future<String?> getSavedToken() => _secureStorage.read(key: 'auth_token');
}
