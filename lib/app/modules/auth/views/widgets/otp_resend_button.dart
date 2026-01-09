import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OtpResendButton extends StatelessWidget {
  final bool resendLoading;
  final VoidCallback onPressed;
  const OtpResendButton({
    super.key,
    required this.resendLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'didnt_receive_otp'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: OutlinedButton(
            onPressed: resendLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child:
                resendLoading
                    ? const CircularProgressIndicator()
                    : Text(
                      'resend_otp'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
