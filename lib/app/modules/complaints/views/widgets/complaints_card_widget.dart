import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/bindings/complaints_bindings.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/get_complaints_controller.dart';
import 'package:goverment_complaints/app/modules/complaints/views/pages/show_complaints_page.dart';

class ComplaintsCardWidget extends StatelessWidget {
  const ComplaintsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final UserComplaintsController complaintsCtrl =
        Get.find<UserComplaintsController>();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: InkWell(
        onTap: () async {
          await complaintsCtrl.fetchUserComplaints();
          Get.to(() => const UserComplaintsView(), binding: ComplaintBinding());
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF003832),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFb9a779),
                ),
                child: Icon(
                  Icons.report_gmailerrorred_rounded,
                  size: 22.r,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 14.w),
              Text(
                'view_all_complaints'.tr,
                style: TextStyle(
                  color: const Color(0xFFedebe0),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Color(0xFFb9a779)),
            ],
          ),
        ),
      ),
    );
  }
}
