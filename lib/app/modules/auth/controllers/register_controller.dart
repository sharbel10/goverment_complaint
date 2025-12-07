import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
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

  Future<RegisterResponse?> register() async {
    final req = RegisterRequest(
      email: email.text.trim(),
      name: name.text.trim(),
      pass: password.text.trim(),
      passConfirm: passwordConfirm.text.trim(),
      idNumber: idNumber.text.trim(),
    );
    isLoading.value = true;
    try {
      final response = await _api.post('register', data: req.toJson());

      final body = response.data;
      final citizenId = response.data['citizen_id'];
      if (citizenId != null) {
        await _secureStorage.write(key: 'citizen', value: citizenId.toString());
      }
      final registerResponse = RegisterResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      return registerResponse;
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
}
