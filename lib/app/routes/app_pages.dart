import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:goverment_complaints/app/modules/auth/views/pages/login_page_view.dart';
import 'package:goverment_complaints/app/modules/auth/views/pages/otp_page_view.dart';
import 'package:goverment_complaints/app/modules/auth/views/pages/register_page_view.dart';

import '../modules/auth/bindings/auth_bindings.dart';
import '../modules/auth/views/pages/notification_page_view.dart';
import '../modules/complaints/bindings/complaints_bindings.dart';
import '../modules/complaints/views/pages/create_complaints_page_view.dart';
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

    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
    ),


  ];
}
