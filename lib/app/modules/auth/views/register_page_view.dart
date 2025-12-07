import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/register_controller.dart';
import 'package:goverment_complaints/app/routes/app_routes.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.find<RegisterController>();

    return Scaffold(
      backgroundColor: const Color(0xFF002623),
      body: Obx(() {
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

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
                    key: controller.formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller.name,
                          decoration: InputDecoration(
                            labelText: "الاسم الثلاثي",
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: controller.idNumber,
                          decoration: InputDecoration(
                            labelText: "الرقم الوطني",
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.credit_card),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: controller.email,
                          decoration: InputDecoration(
                            labelText: "الايميل ",
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: controller.password,
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
                        ),

                        const SizedBox(height: 28),

                        TextFormField(
                          controller: controller.passwordConfirm,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة السر',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // تمت إزالة Obx لأنه لا يحتوي أي observable
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : () async {
                                      final resp = await controller.register();
                                      if (resp != null) {
                                        Get.snackbar(
                                          'نجاح',
                                          resp.message,
                                          backgroundColor: Color(0xFFb9a779),
                                          colorText: Colors.white,
                                        );
                                        // مثال بعد نجاح التسجيل
                                        final citizenId = resp.data?.citizenId;
                                        Get.toNamed(
                                          AppRoutes.otp,
                                          arguments: {'citizen_id': citizenId},
                                        );
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFb9a779),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:
                                controller.isLoading.value
                                    ? CircularProgressIndicator(
                                      color: Color(0xFFb9a779),
                                    )
                                    : Text(
                                      "انشاء حساب",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
