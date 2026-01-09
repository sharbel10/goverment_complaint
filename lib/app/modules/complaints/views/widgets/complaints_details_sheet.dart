import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/models/response/get_complaints_response_model.dart';

class ComplaintDetailsSheet extends StatelessWidget {
  final ComplaintModel complaint;
  final ScrollController scrollController;
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final Future<void> Function(String url) onOpenAttachment;
  final VoidCallback onClose;

  const ComplaintDetailsSheet({
    super.key,
    required this.complaint,
    required this.scrollController,
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
    required this.onOpenAttachment,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 26.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    complaint.referenceNumber,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'complaint_entity_prefix'.trParams({'value': complaint.entity}),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'complaint_type_prefix'.trParams({'value': complaint.type}),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'complaint_location_prefix'.trParams({
                'value': complaint.location,
              }),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              complaint.description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 12.h),
            if (complaint.attachments.isNotEmpty) ...[
              Text(
                'attachments'.tr,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Column(
                children:
                    complaint.attachments.map((url) {
                      final short = url.split('/').last.split('?').first;
                      return AttachmentListTile(
                        filename: short,
                        onOpen: () => onOpenAttachment(url),
                      );
                    }).toList(),
              ),
            ],
            SizedBox(height: 20.h),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'complaint_status_prefix'.trParams({'value': statusText}),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const Spacer(),
                  Text(
                    complaint.createdAt.split('T').first,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text('ok'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttachmentListTile extends StatelessWidget {
  final String filename;
  final VoidCallback onOpen;
  const AttachmentListTile({
    super.key,
    required this.filename,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.link,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      title: Text(
        filename,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 12.sp,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.open_in_new,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        onPressed: onOpen,
      ),
    );
  }
}
