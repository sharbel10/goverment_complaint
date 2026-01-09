import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/register_controller.dart';
import 'package:goverment_complaints/app/routes/app_routes.dart';

class RegisterForm extends StatelessWidget {
  final RegisterController controller;
  const RegisterForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.name,
            decoration: InputDecoration(
              hintText: 'full_name'.tr,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'field_required'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: 18.h),
          TextFormField(
            controller: controller.idNumber,
            decoration: InputDecoration(
              hintText: 'national_id'.tr,
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'field_required'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: 18.h),
          TextFormField(
            controller: controller.email,
            decoration: InputDecoration(
              hintText: 'email'.tr,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'field_required'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: 18.h),
          TextFormField(
            controller: controller.password,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'password'.tr,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'password_required'.tr;
              }
              if (v.length < 6) {
                return 'password_min_length'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: 28.h),
          TextFormField(
            controller: controller.passwordConfirm,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'confirm_password'.tr,
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'field_required'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: 28.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: Obx(() {
              return ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () async {
                          final resp = await controller.register();
                          if (resp != null) {
                            Get.snackbar(
                              'success'.tr,
                              'register_success'.tr,
                              backgroundColor: Theme.of(context).primaryColor,
                              colorText: Colors.white,
                            );
                            final citizenId = resp.data?.citizenId;
                            Get.toNamed(
                              AppRoutes.otp,
                              arguments: {'citizen_id': citizenId},
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child:
                    controller.isLoading.value
                        ? CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        )
                        : Text(
                          'create_account'.tr,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              );
            }),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
