import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/create_complaint_controller.dart';

class SubmitSection extends StatelessWidget {
  const SubmitSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateComplaintController>();

    return Obx(() {
      final loading = controller.isSubmitting.value;
      final progress = controller.uploadProgress.value;

      return Column(
        children: [
          if (loading)
            Column(
              children: [
                LinearProgressIndicator(value: progress),
                SizedBox(height: 8.h),
                Text(
                  'upload_percent'.trParams({
                    'percent': (progress * 100).toStringAsFixed(0),
                  }),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: loading ? null : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFb9a779),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child:
                  loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        "submit_complaint".tr,
                        style: const TextStyle(color: Colors.white),
                      ),
            ),
          ),
        ],
      );
    });
  }
}
