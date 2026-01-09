import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OtpCountdown extends StatelessWidget {
  final int countdown;
  const OtpCountdown({super.key, required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'resend_in'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16.sp,
          ),
        ),
        Text(
          '$countdown ' + 'seconds'.tr,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
