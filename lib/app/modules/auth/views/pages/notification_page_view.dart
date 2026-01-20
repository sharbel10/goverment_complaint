import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/notifications/notifications_controller.dart';
import 'package:goverment_complaints/app/modules/notifications/models/app_notifications.dart';
import 'package:goverment_complaints/app/routes/app_routes.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late final NotificationsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<NotificationsController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.newStatus:
        return const Color(0xFF4FC3F7);
      case NotificationStatus.inProgress:
        return const Color(0xFFFFB74D);
      case NotificationStatus.rejected:
        return const Color(0xFFE57373);
      case NotificationStatus.completed:
        return const Color(0xFF66BB6A);
    }
  }

  IconData _getStatusIcon(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.newStatus:
        return Icons.fiber_new_rounded;
      case NotificationStatus.inProgress:
        return Icons.autorenew_rounded;
      case NotificationStatus.rejected:
        return Icons.cancel_rounded;
      case NotificationStatus.completed:
        return Icons.check_circle_rounded;
    }
  }

  String _getStatusText(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.newStatus:
        return 'جديدة';
      case NotificationStatus.inProgress:
        return 'قيد المعالجة';
      case NotificationStatus.rejected:
        return 'مرفوضة';
      case NotificationStatus.completed:
        return 'منجزة';
    }
  }

  NotificationStatus _mapStatusFromData(AppNotification n) {
    final raw = (n.data['status'] ?? n.data['type'] ?? '').toString();
    final s = raw.toLowerCase();

    if (s.contains('rejected')) return NotificationStatus.rejected;
    if (s.contains('completed')) return NotificationStatus.completed;
    if (s.contains('processing') || s.contains('in_progress')) {
      return NotificationStatus.inProgress;
    }
    return NotificationStatus.newStatus;
  }

  String _headerForMs(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();

    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final yesterday = now.subtract(const Duration(days: 1));
    if (sameDay(dt, now)) return 'اليوم';
    if (sameDay(dt, yesterday)) return 'أمس';

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    if (dt.isAfter(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day))) {
      return 'هذا الأسبوع';
    }

    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _timeForMs(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');

    final isAm = h < 12;
    final hour12 = (h == 0) ? 12 : (h > 12 ? h - 12 : h);
    final ampm = isAm ? 'ص' : 'م';
    return '$hour12:$m $ampm';
  }

  List<_UiNotification> _toUi(List<AppNotification> list) {
    return list.map((n) {
      final status = _mapStatusFromData(n);
      return _UiNotification(
        id: n.id,
        title: n.title,
        message: n.body,
        time: _timeForMs(n.createdAtMs),
        dateHeader: _headerForMs(n.createdAtMs),
        status: status,
        isRead: n.isRead,
        data: n.data,
      );
    }).toList();
  }

  void _openNotificationSheet(_UiNotification notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationDetailsSheet(notification: notification),
    );
  }

  bool _routeExists(String name) =>
      Get.routeTree.routes.any((r) => r.name == name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),

                      SizedBox(width: 8.w),
                      Text(
                        "الإشعارات",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _ctrl.clearAll,
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: Obx(() {
                final ui = _toUi(_ctrl.items);

                if (ui.isEmpty) {
                  return Center(
                    child: Text(
                      'لا يوجد إشعارات بعد',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.8),
                      ),
                    ),
                  );
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index >= ui.length * 2) return null;

                        if (index.isEven) {
                          final itemIndex = index ~/ 2;
                          final n = ui[itemIndex];
                          final isFirstInDate = itemIndex == 0 ||
                              ui[itemIndex - 1].dateHeader != n.dateHeader;

                          return Column(
                            children: [
                              if (isFirstInDate)
                                _buildDateHeader(n.dateHeader, itemIndex),
                              _buildNotificationCard(n, itemIndex),
                            ],
                          );
                        } else {
                          return const SizedBox(height: 12);
                        }
                      }, childCount: ui.length * 2),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.elasticOut,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.1 + (index * 0.1),
                1.0,
                curve: Curves.easeOutBack,
              ),
            ),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(_UiNotification n, int index) {
    final statusColor = _getStatusColor(n.status);

    return AnimatedContainer(
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.2 + (index * 0.1),
                1.0,
                curve: Curves.easeOutBack,
              ),
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.3 + (index * 0.1),
                  1.0,
                  curve: Curves.elasticOut,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    _ctrl.markRead(n.id);

                    final rawId = n.data['complaint_id'];
                    final complaintId = int.tryParse(rawId?.toString() ?? '');

                    if (complaintId != null && _routeExists(AppRoutes.complaintDetails)) {
                      Get.toNamed(AppRoutes.complaintDetails, arguments: complaintId);
                      return;
                    }

                    _openNotificationSheet(n);
                  },
                  highlightColor: statusColor.withOpacity(0.1),
                  splashColor: statusColor.withOpacity(0.2),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: statusColor.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getStatusIcon(n.status),
                            color: statusColor,
                            size: 24.r,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: n.isRead
                                            ? FontWeight.w600
                                            : FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    n.time,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                n.message,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.8),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      _getStatusText(n.status),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!n.isRead)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationDetailsSheet extends StatefulWidget {
  final _UiNotification notification;
  const _NotificationDetailsSheet({required this.notification});

  @override
  State<_NotificationDetailsSheet> createState() =>
      _NotificationDetailsSheetState();
}

class _NotificationDetailsSheetState extends State<_NotificationDetailsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColorFrom(_UiNotification notification) {
    switch (notification.status) {
      case NotificationStatus.newStatus:
        return const Color(0xFF4FC3F7);
      case NotificationStatus.inProgress:
        return const Color(0xFFFFB74D);
      case NotificationStatus.rejected:
        return const Color(0xFFE57373);
      case NotificationStatus.completed:
        return const Color(0xFF66BB6A);
    }
  }

  IconData _statusIconFrom(_UiNotification notification) {
    switch (notification.status) {
      case NotificationStatus.newStatus:
        return Icons.fiber_new_rounded;
      case NotificationStatus.inProgress:
        return Icons.autorenew_rounded;
      case NotificationStatus.rejected:
        return Icons.cancel_rounded;
      case NotificationStatus.completed:
        return Icons.check_circle_rounded;
    }
  }

  String _statusTextFrom(_UiNotification notification) {
    switch (notification.status) {
      case NotificationStatus.newStatus:
        return 'جديدة';
      case NotificationStatus.inProgress:
        return 'قيد المعالجة';
      case NotificationStatus.rejected:
        return 'مرفوضة';
      case NotificationStatus.completed:
        return 'منجزة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColorFrom(widget.notification);

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _statusIconFrom(widget.notification),
                          color: statusColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.notification.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.notification.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الوقت: ${widget.notification.time}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.8),
                              ),
                            ),
                            Text(
                              'التاريخ: ${widget.notification.dateHeader}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            _statusTextFrom(widget.notification),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تم الفهم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UiNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String dateHeader;
  final NotificationStatus status;
  final bool isRead;
  final Map<String, dynamic> data;

  _UiNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.dateHeader,
    required this.status,
    required this.isRead,
    required this.data,
  });
}

enum NotificationStatus { newStatus, inProgress, rejected, completed }
