import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/create_complaint_controller.dart';
import 'package:goverment_complaints/app/modules/complaints/views/widgets/complaints_card_widget.dart';
import 'package:goverment_complaints/app/modules/complaints/views/widgets/complaints_form_section.dart';
import 'package:goverment_complaints/app/modules/complaints/views/widgets/home_header.dart';
import 'package:goverment_complaints/app/modules/complaints/views/widgets/home_top_bar.dart';
import 'package:goverment_complaints/app/modules/complaints/views/widgets/submit_section.dart';
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

  Future<void> _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('logout'.tr),
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
        'done'.tr,
        'logout_success'.tr,
        backgroundColor: const Color(0xFFb9a779),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'logout_failed'.trParams({'error': e.toString()}),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: localFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeTopBar(onPressed: _logout),
                  const HomeHeader(),
                  const ComplaintsCardWidget(),
                  const ComplaintFormSection(),
                  const SubmitSection(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
