import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/create_complaint_controller.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/get_complaints_controller.dart';

class ComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateComplaintController>(() => CreateComplaintController());
    Get.lazyPut<UserComplaintsController>(() => UserComplaintsController());
  }
}
