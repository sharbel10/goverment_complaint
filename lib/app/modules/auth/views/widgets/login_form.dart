import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/auth/bindings/auth_bindings.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/login_controller.dart';
import 'package:goverment_complaints/app/modules/auth/views/pages/register_page_view.dart';
import 'package:goverment_complaints/app/routes/app_routes.dart';

class LoginForm extends StatelessWidget {
  final LoginController controller;
  const LoginForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.email,

            decoration: InputDecoration(
              hintText: 'email_or_phone'.tr,
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
                          final resp = await controller.login();
                          if (resp != null) {
                            Get.snackbar(
                              'success'.tr,
                              resp.message,
                              backgroundColor: const Color(0xFFb9a779),
                              colorText: Colors.white,
                            );
                            Get.offAllNamed(AppRoutes.home);
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFb9a779),
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
                          'login'.tr,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Get.to(RegisterView(), binding: AuthBinding());
                },
                child: Text(
                  'create_account'.tr,

                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Theme.of(context).primaryColor,
                    decorationColor: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
