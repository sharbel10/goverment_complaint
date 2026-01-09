import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/models/request/get_complaints_request.dart';
import 'package:goverment_complaints/app/modules/complaints/models/response/get_complaints_response_model.dart';
import '../../../services/api_service.dart';

class UserComplaintsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final RxBool isLoading = false.obs;
  final RxList<ComplaintModel> complaints = <ComplaintModel>[].obs;

  Future<bool> fetchUserComplaints() async {
    isLoading.value = true;
    try {
      final cidStr = await _storage.read(key: 'citizen_id');
      int? cid = int.tryParse(cidStr ?? '');

      final req = GetUserComplaintsRequest(citizenId: cid!);

      final response = await _api.get('my-complaints', data: req.toJson());

      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = GetUserComplaintsResponse.fromJson(
          Map<String, dynamic>.from(body),
        );

        if (parsed.status.toLowerCase() == 'success') {
          complaints.assignAll(parsed.complaints);
          return true;
        } else {
          Get.snackbar(
            'failed'.tr,
            parsed.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      } else {
        Get.snackbar(
          'error'.tr,
          'unexpected_response'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'error'.tr,
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'unexpected_error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clear() => complaints.clear();
}
