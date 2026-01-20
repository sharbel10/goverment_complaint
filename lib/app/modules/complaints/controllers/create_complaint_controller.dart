import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, Response;
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../../../services/api_service.dart';
import '../models/request/create_complaint_request_model.dart';
import '../models/response/create_complaint_response_model.dart';
import '../../../utils/app_snackbar.dart';

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

      final existingKeys = attachments
          .map(
            (f) => (f.path != null && f.path!.isNotEmpty)
            ? f.path!
            : '${f.name}_${f.size}',
      )
          .toSet();

      final List<PlatformFile> newFiles = [];
      int skipped = 0;

      for (final f in result.files) {
        final key = (f.path != null && f.path!.isNotEmpty)
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

      debugPrint('PICK FILES -> added: ${newFiles.length}, skipped: $skipped');
      for (final f in newFiles) {
        debugPrint(
          'PICK FILE -> name=${f.name}, size=${f.size}, path=${f.path}, ext=${f.extension}',
        );
      }

      if (skipped > 0) {
        showAppSnack(
          title: 'note'.tr,
          message: 'files_skipped'.trParams({'count': skipped.toString()}),
          type: AppSnackType.warning,
        );
      }
    } catch (e) {
      debugPrint('PICK FILES ERROR -> $e');
      showAppSnack(
        title: 'error'.tr,
        message: 'pick_files_error'.tr,
        type: AppSnackType.error,
      );
    }
  }

  void removeAttachment(PlatformFile file) {
    attachments.remove(file);
    debugPrint('REMOVE FILE -> name=${file.name}, path=${file.path}');
  }

  Future<ComplaintSubmitResponse?> submit() async {
    final type = selectedType.value;
    final entity = selectedEntity.value;
    final location = selectedLocation.value;
    final description = descriptionCtrl.text.trim();

    debugPrint('SUBMIT COMPLAINT -> type=$type, entity=$entity, location=$location');
    debugPrint('SUBMIT COMPLAINT -> description length=${description.length}');
    debugPrint('SUBMIT COMPLAINT -> attachments count=${attachments.length}');

    if (type.isEmpty || entity.isEmpty || location.isEmpty || description.isEmpty) {
      debugPrint('SUBMIT COMPLAINT -> validation failed (empty fields)');
      showAppSnack(
        title: 'error'.tr,
        message: 'fill_all_fields'.tr,
        type: AppSnackType.error,
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

      debugPrint('SUBMIT COMPLAINT -> FormData fields: ${form.fields}');
      debugPrint('SUBMIT COMPLAINT -> FormData files count: ${form.files.length}');
      for (final f in form.files) {
        debugPrint('SUBMIT COMPLAINT -> file field=${f.key}, filename=${f.value.filename}');
      }

      late final Response response;

      try {
        response = await _api.upload(
          'submit-complaint',
          formData: form,
          onSendProgress: (sent, total) {
            if (total > 0) {
              uploadProgress.value = sent / total;
            }
            debugPrint('UPLOAD PROGRESS -> $sent / $total');
          },
        );
      } on DioError catch (e) {
        debugPrint('UPLOAD DIO ERROR -> type: ${e.type}');
        debugPrint('UPLOAD DIO ERROR -> message: ${e.message}');
        debugPrint('UPLOAD DIO ERROR -> status: ${e.response?.statusCode}');
        debugPrint('UPLOAD DIO ERROR -> data: ${e.response?.data}');
        rethrow;
      }

      debugPrint('SUBMIT COMPLAINT -> statusCode: ${response.statusCode}');
      debugPrint('SUBMIT COMPLAINT -> headers: ${response.headers.map}');
      debugPrint('SUBMIT COMPLAINT -> data: ${response.data}');

      final body = response.data;

      if (body is Map) {
        final parsed = ComplaintSubmitResponse.fromJson(
          Map<String, dynamic>.from(body),
        );

        debugPrint(
          'SUBMIT COMPLAINT -> parsed.status=${parsed.status}, message=${parsed.message}',
        );

        if (parsed.status.toLowerCase() == 'success') {
          showAppSnack(
            title: 'success'.tr,
            message: parsed.message,
            type: AppSnackType.success,
          );
          return parsed;
        } else {
          showAppSnack(
            title: 'failed'.tr,
            message: parsed.message,
            type: AppSnackType.error,
          );
          return parsed;
        }
      } else {
        debugPrint('SUBMIT COMPLAINT -> unexpected response type: ${body.runtimeType}');
        showAppSnack(
          title: 'error'.tr,
          message: 'unexpected_response'.tr,
          type: AppSnackType.error,
        );
        return null;
      }
    } on ApiException catch (e) {
      debugPrint('SUBMIT COMPLAINT -> ApiException: ${e.message} (code: ${e.statusCode})');
      showAppSnack(
        title: 'error'.tr,
        message: e.message,
        type: AppSnackType.error,
      );
      return null;
    } catch (e) {
      debugPrint('SUBMIT COMPLAINT -> Unexpected error: $e');
      showAppSnack(
        title: 'error'.tr,
        message: e.toString(),
        type: AppSnackType.error,
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

    debugPrint('CLEAR FORM -> done');
  }
}
