import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/login_controller.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/auth_header.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/auth_logo.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/login_form.dart';
import 'package:goverment_complaints/app/services/locale_service.dart';
import 'package:goverment_complaints/app/services/theme_service.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder(
        init: controller,
        builder: (controller) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.language,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          onPressed: () {
                            final localeService = Get.find<LocaleService>();
                            if (Get.locale?.languageCode == 'en') {
                              localeService.changeLocale('ar');
                            } else {
                              localeService.changeLocale('en');
                            }
                          },
                          tooltip: 'switch_language'.tr,
                        ),
                        IconButton(
                          icon: Icon(
                            Get.find<ThemeService>().themeMode == ThemeMode.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          onPressed: () {
                            Get.find<ThemeService>().switchTheme();
                          },
                          tooltip: 'Switch Theme',
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    AuthLogo(),

                    SizedBox(height: 30.h),
                    AuthHeader(),

                    SizedBox(height: 40.h),

                    LoginForm(controller: controller),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
