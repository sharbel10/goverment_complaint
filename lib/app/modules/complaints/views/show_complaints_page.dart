import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/views/pdf_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:goverment_complaints/app/modules/complaints/controllers/get_complaints_controller.dart';
import 'package:goverment_complaints/app/modules/complaints/models/response/get_complaints_response_model.dart';
import 'package:goverment_complaints/app/services/api_service.dart';

class UserComplaintsView extends StatefulWidget {
  const UserComplaintsView({super.key});

  @override
  State<UserComplaintsView> createState() => _UserComplaintsViewState();
}

class _UserComplaintsViewState extends State<UserComplaintsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late final UserComplaintsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<UserComplaintsController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _load();
    });
  }

  Future<void> _load() async {
    await _controller.fetchUserComplaints();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ---------- Helper Methods ----------
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF4FC3F7);
      case 'in_progress':
      case 'inprogress':
      case 'processing':
        return const Color(0xFFFFB74D);
      case 'rejected':
        return const Color(0xFFE57373);
      case 'completed':
      case 'done':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFFb9a779);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Icons.fiber_new_rounded;
      case 'in_progress':
      case 'processing':
        return Icons.autorenew_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return 'جديدة';
      case 'in_progress':
      case 'processing':
        return 'قيد المعالجة';
      case 'rejected':
        return 'مرفوضة';
      case 'completed':
        return 'منجزة';
      default:
        return status;
    }
  }

  Future<void> _openAttachment(String url) async {
    final ApiService api = Get.find<ApiService>();

    if (url.isEmpty) {
      Get.snackbar('خطأ', 'رابط المرفق غير صالح');
      return;
    }

    final lower = url.toLowerCase();
    final isImage =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif');
    final isPdf = lower.endsWith('.pdf');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFb9a779)),
          ),
    );

    try {
      print("Downloading from: $url");

      final Uint8List bytes = await api.downloadFileBytes(url);

      Navigator.of(context).pop();

      if (isImage) {
        await showDialog(
          context: context,
          builder:
              (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: InteractiveViewer(child: Image.memory(bytes)),
              ),
        );
      } else if (isPdf) {
        final tempDir = await getTemporaryDirectory();
        final filename = url.split('/').last.split('?').first;
        final file = File('${tempDir.path}/$filename.pdf');
        await file.writeAsBytes(bytes, flush: true);

        await Get.to(() => PdfViewPage(file: file));
      } else {
        final tempDir = await getTemporaryDirectory();
        String filename = url.split('/').last.split('?').first;
        if (filename.isEmpty) filename = 'attachment';
        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(bytes, flush: true);

        final launched = await launchUrl(
          Uri.file(file.path),
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          Get.snackbar(
            'خطأ',
            'تعذّر فتح الملف تلقائياً. الملف محفوظ في: ${file.path}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      Get.snackbar(
        'خطأ',
        'تعذر تحميل أو فتح الملف: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print(e);
    }
  }

  // ---------- Complaint Details ----------
  void _showComplaintDetails(ComplaintModel c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final statusColor = _statusColor(c.status);
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF003832),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
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
                            _statusIcon(c.status),
                            color: statusColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            c.referenceNumber,
                            style: const TextStyle(
                              color: Color(0xFFedebe0),
                              fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 12),
                    Text(
                      'الجهة: ${c.entity}',
                      style: const TextStyle(color: Color(0xFFedebe0)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'النوع: ${c.type}',
                      style: const TextStyle(color: Color(0xFFedebe0)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الموقع: ${c.location}',
                      style: const TextStyle(color: Color(0xFFedebe0)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      c.description,
                      style: const TextStyle(color: Color(0xFFedebe0)),
                    ),
                    const SizedBox(height: 12),
                    if (c.attachments.isNotEmpty) ...[
                      const Text(
                        'المرفقات',
                        style: TextStyle(
                          color: Color(0xFFb9a779),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children:
                            c.attachments.map((url) {
                              final short =
                                  url.split('/').last.split('?').first;
                              return ListTile(
                                leading: const Icon(
                                  Icons.link,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  short,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.open_in_new,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _openAttachment(url),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002623),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'الحالة: ${_statusText(c.status)}',
                            style: const TextStyle(color: Color(0xFFb9a779)),
                          ),
                          const Spacer(),
                          Text(
                            c.createdAt.split('T').first,
                            style: const TextStyle(color: Color(0xFFb9a779)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFb9a779),
                        ),
                        child: const Text('حسناً'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(ComplaintModel c, int index) {
    final statusColor = _statusColor(c.status);
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 40)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: const Color(0xFF003832),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showComplaintDetails(c),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(_statusIcon(c.status), color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.referenceNumber,
                        style: const TextStyle(
                          color: Color(0xFFedebe0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFFedebe0)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            c.createdAt.split('T').first,
                            style: const TextStyle(
                              color: Color(0xFFb9a779),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            c.location,
                            style: const TextStyle(
                              color: Color(0xFFb9a779),
                              fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002623),
      body: SafeArea(
        child: Column(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                        'شكاويي',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFb9a779),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFb9a779)),
                  );
                }
                final list = _controller.complaints;
                if (list.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFFb9a779),
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        Icon(Icons.inbox, size: 80, color: Color(0xFFb9a779)),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'لا توجد شكاوى',
                            style: TextStyle(color: Color(0xFFedebe0)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: const Color(0xFFb9a779),
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    itemCount: list.length,
                    itemBuilder:
                        (context, index) => _buildCard(list[index], index),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
