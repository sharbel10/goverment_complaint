import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:goverment_complaints/app/modules/complaints/bindings/complaints_bindings.dart';
import 'package:goverment_complaints/app/modules/complaints/views/create_complaints_page_view.dart';
import 'package:goverment_complaints/app/modules/auth/views/otp_page_view.dart';
import 'package:goverment_complaints/app/modules/auth/views/register_page_view.dart';

import '../modules/auth/bindings/auth_bindings.dart';
import '../modules/auth/views/login_page_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: ComplaintBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => OTPVerificationView(),
      binding: AuthBinding(),
    ),
  ];
}
