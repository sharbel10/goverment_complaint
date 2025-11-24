
import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

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
    // مؤقت: سكافولد فاضي للهوم
    GetPage(
      name: AppRoutes.home,
      page: () => const Placeholder(),
    ),
  ];
}
