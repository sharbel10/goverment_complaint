import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpFields extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Future<void> Function() onComplete;
  const OtpFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          width: 50.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  controllers[index].text.isEmpty
                      ? Theme.of(context).primaryColor.withOpacity(0.3)
                      : Theme.of(context).primaryColor,
              width: 2,
            ),
            boxShadow: [
              if (controllers[index].text.isNotEmpty)
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) async {
              if (value.isNotEmpty && index == 5) {
                await Future.delayed(const Duration(milliseconds: 100));
                await onComplete();
              }
            },
          ),
        );
      }),
    );
  }
}
