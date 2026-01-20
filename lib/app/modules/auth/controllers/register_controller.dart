import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart' as dio;

import 'package:goverment_complaints/app/modules/auth/models/request/register_request_model.dart';
import 'package:goverment_complaints/app/modules/auth/models/response/register_response_model.dart';
import '../../../services/api_service.dart';

class RegisterController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController idNumber = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController passwordConfirm = TextEditingController();

  var isLoading = false.obs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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

  Future<void> _syncFcmToken(int citizenId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      debugPrint('REGISTER -> syncing fcm token length=${token.length} citizenId=$citizenId');

      final dio.Response res = await _api.post(
        'fcm_token/$citizenId',
        data: {'fcm_token': token},
      );

      _debugPrintDioResponse(res, tag: 'FCM_SYNC');
    } catch (e) {
      debugPrint('REGISTER -> FCM sync failed: $e');
    }
  }

  Future<RegisterResponse?> register() async {
    if (!formKey.currentState!.validate()) return null;

    final req = RegisterRequest(
      email: email.text.trim(),
      name: name.text.trim(),
      pass: password.text.trim(),
      passConfirm: passwordConfirm.text.trim(),
      idNumber: idNumber.text.trim(),
    );

    debugPrint('REGISTER -> request body: ${req.toJson()}');

    isLoading.value = true;
    try {
      final dio.Response response = await _api.post('register', data: req.toJson());

      _debugPrintDioResponse(response, tag: 'REGISTER');

      final body = response.data;
      if (body is! Map) {
        debugPrint('REGISTER -> Unexpected response type: ${body.runtimeType}');
        return null;
      }

      final registerResponse = RegisterResponse.fromJson(Map<String, dynamic>.from(body));

      final citizenId = registerResponse.data?.citizenId;
      debugPrint('REGISTER -> parsed citizenId: $citizenId');

      if (citizenId != null) {
        await _secureStorage.write(key: 'citizen_id', value: citizenId.toString());
        debugPrint('REGISTER -> citizen_id saved ');

        await _syncFcmToken(citizenId);
      }

      return registerResponse;
    } on ApiException catch (e, st) {
      debugPrint('REGISTER -> ApiException: ${e.message} (code: ${e.statusCode})');
      debugPrint('REGISTER -> StackTrace: $st');
      return null;
    } catch (e, st) {
      debugPrint('REGISTER -> Exception: $e');
      debugPrint('REGISTER -> StackTrace: $st');
      return null;
    } finally {
      isLoading.value = false;
      debugPrint('REGISTER -> isLoading=false');
    }
  }

}
