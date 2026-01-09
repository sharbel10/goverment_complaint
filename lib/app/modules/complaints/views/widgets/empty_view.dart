import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EmptyComplaintsView extends StatelessWidget {
  const EmptyComplaintsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 80.h),
        Icon(Icons.inbox, size: 80, color: Theme.of(context).primaryColor),
        SizedBox(height: 12.h),
        Center(
          child: Text(
            'no_complaints'.tr,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
}
