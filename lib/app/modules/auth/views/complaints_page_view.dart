import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'notification_page_view.dart';

class HomeView extends GetView<AuthController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> localFormKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFF002623),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Row(
                  children: [
                    Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Get.to(NotificationsView());
                      },
                    ),
                  ],
                ),
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
                  "يمكنك تقديم شكوى بكل شفافية , الشكوى تساهم في حل المشاكل والاصلاح",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFFedebe0)),
                ),

                const SizedBox(height: 40),

                Form(
                  key: localFormKey,
                  child: Column(
                    children: [
                      _buildField(
                        "نوع الشكوى",
                        Icons.featured_play_list_outlined,
                      ),
                      const SizedBox(height: 18),
                      _buildField("الجهة", Icons.person),
                      const SizedBox(height: 18),
                      _buildField("الموقع", Icons.place_outlined),
                      const SizedBox(height: 18),
                      _buildDescriptionField(),
                      const SizedBox(height: 18),
                      _buildFilePickerPlaceholder(),
                      const SizedBox(height: 18),

                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : controller.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFb9a779),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:
                                controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "ارسال",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Icon(Icons.send, color: Colors.white),
                                      ],
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
      ),
    );
  }

  // ---------------- Widgets -------------------

  Widget _buildField(String label, IconData icon) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        maxLines: 4,
        decoration: InputDecoration(
          labelText: "وصف المشكلة",
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.description_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Get.snackbar(
              "تنبيه",
              "تم النقر على زر اختيار ملف (محاكي)",
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          icon: const Icon(Icons.attach_file),
          label: const Text("إرفاق صورة أو ملف"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "لم يتم اختيار أي ملف",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
