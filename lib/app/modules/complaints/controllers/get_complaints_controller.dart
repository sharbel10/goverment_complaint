import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/models/request/get_complaints_request.dart';
import 'package:goverment_complaints/app/modules/complaints/models/response/get_complaints_response_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_snackbar.dart';

class UserComplaintsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final RxBool isLoading = false.obs;
  final RxList<ComplaintModel> complaints = <ComplaintModel>[].obs;

  Future<bool> fetchUserComplaints() async {
    isLoading.value = true;
    try {
      final cidStr = await _storage.read(key: 'citizen_id');
      final cid = int.tryParse(cidStr ?? '');

      if (cid == null || cid == 0) {
        showAppSnack(
          title: 'error'.tr,
          message: 'citizen_id_missing'.tr,
          type: AppSnackType.error,
        );
        return false;
      }

      final req = GetUserComplaintsRequest(citizenId: cid);

      final response = await _api.get('my-complaints', data: req.toJson());

      final body = response.data;

      if (body is Map) {
        final parsed = GetUserComplaintsResponse.fromJson(
          Map<String, dynamic>.from(body),
        );

        if (parsed.status.toLowerCase() == 'success') {
          complaints.assignAll(parsed.complaints);
          return true;
        } else {
          showAppSnack(
            title: 'failed'.tr,
            message: parsed.message,
            type: AppSnackType.error,
          );
          return false;
        }
      } else {
        showAppSnack(
          title: 'error'.tr,
          message: 'unexpected_response'.tr,
          type: AppSnackType.error,
        );
        return false;
      }
    } on ApiException catch (e) {
      showAppSnack(
        title: 'error'.tr,
        message: e.message,
        type: AppSnackType.error,
      );
      return false;
    } catch (e) {
      showAppSnack(
        title: 'unexpected_error'.tr,
        message: e.toString(),
        type: AppSnackType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clear() => complaints.clear();
}
