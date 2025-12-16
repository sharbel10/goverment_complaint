import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:goverment_complaints/app/modules/auth/views/notification_page_view.dart';
import 'package:goverment_complaints/app/modules/complaints/bindings/complaints_bindings.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/create_complaint_controller.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/get_complaints_controller.dart';
import 'package:goverment_complaints/app/modules/complaints/views/show_complaints_page.dart';
import 'package:goverment_complaints/app/routes/app_routes.dart';
import 'package:goverment_complaints/app/services/api_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<FormState> localFormKey = GlobalKey<FormState>();

  final CreateComplaintController controller =
      Get.find<CreateComplaintController>();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiService _api = Get.find<ApiService>();
  List<String> syrianGovernorates = [
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'دير الزور',
    'الرقة',
    'الحسكة',
    'درعا',
    'السويداء',
    'القنيطرة',
  ];
  List<String> complaintEntities = [
    'وزارة الكهرباء',
    'وزارة المياه',
    'وزارة الاتصالات',
    'البلدية',
    'المرور',
    'جهة أخرى',
  ];
  List<String> complaintTypes = [
    'خدمات',
    'كهرباء',
    'مياه',
    'اتصالات',
    'نظافة',
    'مرور',
    'أخرى',
  ];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickFiles() async {
    await controller.pickFiles();
  }

  Future<void> _submit() async {
    if (!localFormKey.currentState!.validate()) return;

    final result = await controller.submit();

    if (result != null && result.status.toLowerCase() == 'success') {
      final ref = result.data?.referenceNumber ?? '---';

      Get.dialog(
        AlertDialog(
          title: const Text('تم إرسال الشكوى'),
          content: Text('رقم المرجع: $ref'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('حسناً')),
          ],
        ),
      );

      controller.clearAll();
    }
  }

  Future<void> _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج حقًا؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'citizen_id');
      await _secureStorage.delete(key: 'citizen');

      try {
        _api.setAuthToken('');
      } catch (_) {}

      controller.clearAll();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'تم',
        'تم تسجيل الخروج بنجاح',
        backgroundColor: const Color(0xFFb9a779),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر تسجيل الخروج: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'الحقل مطلوب' : null,
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
        controller: controller.descriptionCtrl,
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
        validator: (v) => (v == null || v.isEmpty) ? 'الحقل مطلوب' : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required RxString selectedValue,
    IconData? icon,
  }) {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: selectedValue.value.isEmpty ? null : selectedValue.value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: (v) {
          if (v != null) selectedValue.value = v;
        },
        validator: (v) => (v == null || v.isEmpty) ? 'الحقل مطلوب' : null,
      );
    });
  }

  Widget _buildFilePickerPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _pickFiles,
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
        Obx(() {
          final picked = controller.attachments;
          if (picked.isEmpty) {
            return const Text(
              "لم يتم اختيار أي ملف",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            );
          } else {
            return Column(
              children:
                  picked.map((f) {
                    final sizeKB = (f.size / 1024).toStringAsFixed(1);
                    return ListTile(
                      leading: const Icon(
                        Icons.insert_drive_file,
                        color: Colors.white,
                      ),
                      title: Text(
                        f.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '$sizeKB KB',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          controller.removeAttachment(f);
                        },
                      ),
                    );
                  }).toList(),
            );
          }
        }),
      ],
    );
  }

  Widget _buildComplaintsCard() {
    final UserComplaintsController complaintsCtrl =
        Get.find<UserComplaintsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () async {
          try {
            await complaintsCtrl.fetchUserComplaints();
            Get.to(
              () => const UserComplaintsView(),
              binding: ComplaintBinding(),
            );
          } catch (e) {
            Get.snackbar('خطأ', 'تعذر جلب الشكاوي');
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF003832),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFb9a779).withOpacity(0.12),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFb9a779),
                ),
                child: const Icon(
                  Icons.report_gmailerrorred_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'عرض كل الشكاوي الخاصة بك',
                    style: TextStyle(
                      color: Color(0xFFedebe0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              const Icon(Icons.chevron_right, color: Color(0xFFb9a779)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002623),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: localFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                        tooltip: 'تسجيل الخروج',
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Get.to(() => const NotificationsView());
                        },
                      ),
                    ],
                  ),

                  // logo
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

                  const SizedBox(height: 22),

                  const Text(
                    "نظام الشكاوي الحكومية",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFb9a779),
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    "يمكنك تقديم شكوى بكل شفافية , الشكوى تساهم في حل المشاكل والاصلاح",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFFedebe0)),
                  ),

                  _buildComplaintsCard(),

                  const SizedBox(height: 6),

                  const SizedBox(height: 6),
                  _buildDropdown(
                    label: 'نوع الشكوى',
                    items: complaintTypes,
                    selectedValue: controller.selectedType,
                    icon: Icons.featured_play_list_outlined,
                  ),
                  const SizedBox(height: 18),

                  _buildDropdown(
                    label: 'الجهة',
                    items: complaintEntities,
                    selectedValue: controller.selectedEntity,
                    icon: Icons.account_balance,
                  ),
                  const SizedBox(height: 18),

                  _buildDropdown(
                    label: 'الموقع',
                    items: syrianGovernorates,
                    selectedValue: controller.selectedLocation,
                    icon: Icons.place_outlined,
                  ),

                  // _buildField(
                  //   "نوع الشكوى",
                  //   controller.typeCtrl,
                  //   icon: Icons.featured_play_list_outlined,
                  // ),
                  // const SizedBox(height: 18),
                  // _buildField(
                  //   "الجهة",
                  //   controller.entityCtrl,
                  //   icon: Icons.person,
                  // ),
                  // const SizedBox(height: 18),
                  // _buildField(
                  //   "الموقع",
                  //   controller.locationCtrl,
                  //   icon: Icons.place_outlined,
                  // ),
                  const SizedBox(height: 18),
                  _buildDescriptionField(),
                  const SizedBox(height: 18),
                  _buildFilePickerPlaceholder(),
                  const SizedBox(height: 18),

                  Obx(() {
                    final loading = controller.isSubmitting.value;
                    final progress = controller.uploadProgress.value;
                    return Column(
                      children: [
                        if (loading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                LinearProgressIndicator(value: progress),
                                const SizedBox(height: 8),
                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}% تم',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFb9a779),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:
                                loading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      "إرسال الشكوى",
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
