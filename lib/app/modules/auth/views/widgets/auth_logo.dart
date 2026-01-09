import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
