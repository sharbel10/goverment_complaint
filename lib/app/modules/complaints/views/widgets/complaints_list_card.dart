import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goverment_complaints/app/modules/complaints/models/response/get_complaints_response_model.dart';

class ComplaintCardWidget extends StatelessWidget {
  final ComplaintModel complaint;
  final int index;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  const ComplaintCardWidget({
    super.key,
    required this.complaint,
    required this.index,
    required this.statusColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 40)),
      curve: Curves.easeOutBack,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(statusIcon, color: statusColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.referenceNumber,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        complaint.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            complaint.createdAt.split('T').first,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            complaint.location,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
