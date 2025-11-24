import 'package:get/get.dart';
import 'package:goverment_complaints/app/services/network_service.dart';

import '../../../services/api_service.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<NetworkService>()) {
      Get.lazyPut<NetworkService>(() => NetworkService(), fenix: true);
    }

    Get.lazyPut<AuthController>(() => AuthController());
  }
}
