import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, Response;
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../services/api_service.dart';
import '../models/request/create_complaint_request_model.dart';
import '../models/response/create_complaint_response_model.dart';

class CreateComplaintController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final RxString selectedType = ''.obs;
  final RxString selectedEntity = ''.obs;
  final RxString selectedLocation = ''.obs;

  final TextEditingController descriptionCtrl = TextEditingController();

  final RxList<PlatformFile> attachments = <PlatformFile>[].obs;

  final RxBool isSubmitting = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  @override
  void onClose() {
    descriptionCtrl.dispose();
    super.onClose();
  }

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: false,
      );

      if (result == null) return;

      final existingKeys =
          attachments
              .map(
                (f) =>
                    (f.path != null && f.path!.isNotEmpty)
                        ? f.path!
                        : '${f.name}_${f.size}',
              )
              .toSet();

      final List<PlatformFile> newFiles = [];
      int skipped = 0;

      for (final f in result.files) {
        final key =
            (f.path != null && f.path!.isNotEmpty)
                ? f.path!
                : '${f.name}_${f.size}';
        if (!existingKeys.contains(key)) {
          newFiles.add(f);
          existingKeys.add(key);
        } else {
          skipped++;
        }
      }

      if (newFiles.isNotEmpty) {
        attachments.addAll(newFiles);
      }

      if (skipped > 0) {
        Get.snackbar(
          'note'.tr,
          'files_skipped'.trParams({'count': skipped.toString()}),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'pick_files_error'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeAttachment(PlatformFile file) {
    attachments.remove(file);
  }

  Future<ComplaintSubmitResponse?> submit() async {
    final type = selectedType.value;
    final entity = selectedEntity.value;
    final location = selectedLocation.value;
    final description = descriptionCtrl.text.trim();

    if (type.isEmpty ||
        entity.isEmpty ||
        location.isEmpty ||
        description.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'fill_all_fields'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }

    final req = ComplaintRequest(
      type: type,
      entity: entity,
      description: description,
      location: location,
      attachments: attachments.isEmpty ? null : attachments.toList(),
    );

    isSubmitting.value = true;
    uploadProgress.value = 0.0;

    try {
      final FormData form = await req.toFormData();

      final Response response = await _api.upload(
        'submit-complaint',
        formData: form,
        onSendProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
          }
        },
      );

      final body = response.data;
      if (body is Map<String, dynamic>) {
        final parsed = ComplaintSubmitResponse.fromJson(body);
        if (parsed.status.toLowerCase() == 'success') {
          Get.snackbar(
            'success'.tr,
            parsed.message,
            backgroundColor: Color(0xFFb9a779),
            colorText: Colors.white,
          );
          return parsed;
        } else {
          Get.snackbar(
            'failed'.tr,
            parsed.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return parsed;
        }
      } else {
        Get.snackbar(
          'error'.tr,
          'unexpected_response'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'error'.tr,
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isSubmitting.value = false;
      uploadProgress.value = 0.0;
    }
  }

  void clearAll() {
    selectedType.value = '';
    selectedEntity.value = '';
    selectedLocation.value = '';
    descriptionCtrl.clear();
    attachments.clear();
    uploadProgress.value = 0.0;
  }
}
