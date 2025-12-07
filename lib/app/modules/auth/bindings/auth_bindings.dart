import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/login_controller.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/register_controller.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/verify_otp_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
    Get.lazyPut<VerifyOtpController>(() => VerifyOtpController());
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
