import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 140.h,
          width: 140.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.r),
            image: const DecorationImage(
              image: AssetImage(
                'assets/images/syrian-republic-logo-png_seeklogo-622502.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 22.h),
        Text(
          "govt_complaints_system".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFb9a779),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "app_subtitle".tr,
          textAlign: TextAlign.center,

          style: TextStyle(fontSize: 14.sp, color: const Color(0xFFedebe0)),
        ),
      ],
    );
  }
}
