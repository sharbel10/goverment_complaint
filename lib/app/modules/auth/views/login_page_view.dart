import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:goverment_complaints/app/modules/auth/views/register_page_view.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002623),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                /// LOGO
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/images/syrian-republic-logo-png_seeklogo-622502.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "نظام الشكاوى الحكومية",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFb9a779),
                  ),
                ),

                const SizedBox(height: 8),
                const Text(
                  "تقديم الشكاوى، تتبع القضايا، والبقاء على اطلاع",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFFedebe0)),
                ),

                const SizedBox(height: 40),

                Form(
                  key: controller.formKey.value,
                  child: Column(
                    children: [
                      /// Email
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "الايميل او رقم الهاتف",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => controller.email.value = v,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'الحقل مطلوب';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      /// Password
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'كلمة السر',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => controller.password.value = v,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'كلمة السر مطلوبة';
                          }
                          if (v.length < 6) {
                            return 'يجب ان تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      /// Login Button + isLoading (Obx USES observable correctly)
                      Obx(
                            () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.login(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFb9a779),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.to(RefgisterView());
                            },
                            child: const Text(
                              "انشاء حساب",
                              style: TextStyle(
                                color: Color(0xFFb9a779),
                                decorationColor: Color(0xFFb9a779),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "هل نسيت كلمة السر؟",
                              style: TextStyle(
                                color: Color(0xFFb9a779),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFFb9a779),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
