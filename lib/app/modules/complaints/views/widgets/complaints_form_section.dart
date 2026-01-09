import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/create_complaint_controller.dart';

class ComplaintFormSection extends StatelessWidget {
  const ComplaintFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateComplaintController>();
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
    return Column(
      children: [
        ComplaintDropdown(
          label: 'complaint_type'.tr,
          items: complaintTypes,
          value: controller.selectedType,
          icon: Icons.featured_play_list_outlined,
        ),
        SizedBox(height: 18.h),
        ComplaintDropdown(
          label: 'entity'.tr,
          items: complaintEntities,
          value: controller.selectedEntity,
          icon: Icons.account_balance,
        ),
        SizedBox(height: 18.h),
        ComplaintDropdown(
          label: 'location'.tr,
          items: syrianGovernorates,
          value: controller.selectedLocation,
          icon: Icons.place_outlined,
        ),
        SizedBox(height: 18.h),
        const ComplaintDescriptionField(),
        SizedBox(height: 18.h),
        const AttachmentsSection(),
      ],
    );
  }
}

class ComplaintDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final RxString value;
  final IconData? icon;

  const ComplaintDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: value.value.isEmpty ? null : value.value,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        isExpanded: true,
        style: Theme.of(context).textTheme.bodyMedium,
        dropdownColor: Theme.of(context).cardColor,
        iconEnabledColor: Theme.of(context).iconTheme.color,
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
                .toList(),
        onChanged: (v) {
          if (v != null) value.value = v;
        },
        validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr : null,
      );
    });
  }
}

class ComplaintDescriptionField extends StatelessWidget {
  const ComplaintDescriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateComplaintController controller =
        Get.find<CreateComplaintController>();

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller.descriptionCtrl,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "problem_description".tr,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          prefixIcon: const Icon(Icons.description_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr : null,
      ),
    );
  }
}

class AttachmentsSection extends StatelessWidget {
  const AttachmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateComplaintController controller =
        Get.find<CreateComplaintController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => controller.pickFiles(),
          icon: const Icon(Icons.attach_file),
          label: Text("attach_file".tr),
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
            return Text(
              "no_file_selected".tr,
              style: const TextStyle(color: Colors.white70),
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
}
