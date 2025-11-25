import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'تم تقديم شكوى جديدة',
      message: 'تم استلام شكوى بخصوص خدمات البلدية في منطقة المزة',
      time: '10:30 ص',
      date: 'اليوم',
      status: NotificationStatus.newStatus,
    ),
    NotificationItem(
      id: '2',
      title: 'الشكوى قيد المعالجة',
      message: 'تم تحويل الشكوى رقم #12345 إلى قسم الخدمات الفنية',
      time: '09:15 ص',
      date: 'اليوم',
      status: NotificationStatus.inProgress,
    ),
    NotificationItem(
      id: '3',
      title: 'تم رفض الشكوى',
      message: 'تم رفض الشكوى رقم #12344 بسبب عدم اكتمال المعلومات',
      time: '05:20 م',
      date: 'أمس',
      status: NotificationStatus.rejected,
    ),
    NotificationItem(
      id: '4',
      title: 'شكوى منجزة',
      message: 'تم حل الشكوى رقم #12343 بنجاح وإغلاق الملف',
      time: '11:45 ص',
      date: 'أمس',
      status: NotificationStatus.completed,
    ),
    NotificationItem(
      id: '5',
      title: 'تحديث حالة الشكوى',
      message: 'تم نقل الشكوى إلى مرحلة التحقيق الميداني',
      time: '10:30 ص',
      date: 'هذا الأسبوع',
      status: NotificationStatus.inProgress,
    ),
    NotificationItem(
      id: '6',
      title: 'شكوى جديدة',
      message: 'تم استلام شكوى بخصوص النظافة في منطقة الشعلان',
      time: 'الاثنين',
      date: 'هذا الأسبوع',
      status: NotificationStatus.newStatus,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // تأخير بسيط لضمان تحميل الواجهة أولاً
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002623),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002623),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFFb9a779),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "الإشعارات",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFb9a779),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFb9a779),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // قائمة الإشعارات
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) => true,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= notifications.length * 2) return null;

                          if (index.isEven) {
                            final itemIndex = index ~/ 2;
                            final notification = notifications[itemIndex];
                            final isFirstInDate = itemIndex == 0 ||
                                notifications[itemIndex - 1].date != notification.date;

                            return Column(
                              children: [
                                // عنوان التاريخ
                                if (isFirstInDate)
                                  _buildDateHeader(notification.date, itemIndex),

                                // بطاقة الإشعار
                                _buildNotificationCard(notification, itemIndex),
                              ],
                            );
                          } else {
                            return const SizedBox(height: 12);
                          }
                        },
                        childCount: notifications.length * 2,
                      ),
                    ),
                  ],
                ),
              ),
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
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.1 + (index * 0.1),
              1.0,
              curve: Curves.easeOutBack,
            ),
          )),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFb9a779),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    final statusColor = _getStatusColor(notification.status);

    return AnimatedContainer(
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.2 + (index * 0.1),
              1.0,
              curve: Curves.easeOutBack,
            ),
          )),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.3 + (index * 0.1),
                1.0,
                curve: Curves.elasticOut,
              ),
            )),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF003832),
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
                  onTap: () => _showNotificationDetails(notification),
                  highlightColor: statusColor.withOpacity(0.1),
                  splashColor: statusColor.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // أيقونة الحالة
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
                            _getStatusIcon(notification.status),
                            color: statusColor,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // محتوى الإشعار
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // العنوان والوقت
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFedebe0),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    notification.time,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFFb9a779).withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // الرسالة
                              Text(
                                notification.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFFedebe0).withOpacity(0.8),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 8),

                              // حالة الإشعار
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(notification.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
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

  void _showNotificationDetails(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _NotificationDetailsSheet(notification: notification);
      },
    );
  }
}

class _NotificationDetailsSheet extends StatefulWidget {
  final NotificationItem notification;

  const _NotificationDetailsSheet({required this.notification});

  @override
  State<_NotificationDetailsSheet> createState() => _NotificationDetailsSheetState();
}

class _NotificationDetailsSheetState extends State<_NotificationDetailsSheet> with SingleTickerProviderStateMixin {
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

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.notification.status);

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF003832),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor,
                width: 2,
              ),
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
                  // الرأس
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(widget.notification.status),
                          color: statusColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.notification.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFedebe0),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFFb9a779),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // المحتوى
                  Text(
                    widget.notification.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFFedebe0).withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // التوقيت والحالة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002623),
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
                                color: const Color(0xFFb9a779).withOpacity(0.8),
                              ),
                            ),
                            Text(
                              'التاريخ: ${widget.notification.date}',
                              style: TextStyle(
                                color: const Color(0xFFb9a779).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor,
                            ),
                          ),
                          child: Text(
                            _getStatusText(widget.notification.status),
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

                  // زر الإغلاق
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFb9a779),
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

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String date;
  final NotificationStatus status;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.date,
    required this.status,
  });
}

enum NotificationStatus {
  newStatus,
  inProgress,
  rejected,
  completed,
}