import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/complaints/views/pages/pdf_page.dart';
import 'package:goverment_complaints/app/modules/complaints/views/widgets/complaints_details_sheet.dart';
import 'package:goverment_complaints/app/modules/complaints/views/widgets/complaints_list_card.dart'
    show ComplaintCardWidget;
import 'package:goverment_complaints/app/modules/complaints/views/widgets/empty_view.dart';
import 'package:goverment_complaints/app/modules/complaints/views/widgets/user_complaints_header.dart';
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
        return Theme.of(context).primaryColor;
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
        return 'new'.tr;
      case 'in_progress':
      case 'processing':
        return 'in_progress'.tr;
      case 'rejected':
        return 'rejected'.tr;
      case 'completed':
        return 'completed'.tr;
      default:
        return status;
    }
  }

  Future<void> _openAttachment(String url) async {
    final ApiService api = Get.find<ApiService>();

    if (url.isEmpty) {
      Get.snackbar('error'.tr, 'invalid_attachment_link'.tr);
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
          (_) => Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
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
            'error'.tr,
            'auto_open_failed'.trParams({'path': file.path}),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      Get.snackbar(
        'error'.tr,
        'download_error'.trParams({'error': e.toString()}),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print(e);
    }
  }

  void _showComplaintDetails(ComplaintModel c) {
    final statusColor = _statusColor(c.status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return ComplaintDetailsSheet(
              complaint: c,
              scrollController: controller,
              statusColor: statusColor,
              statusIcon: _statusIcon(c.status),
              statusText: _statusText(c.status),
              onOpenAttachment: _openAttachment,
              onClose: () => Navigator.pop(context),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(ComplaintModel c, int index) {
    final statusColor = _statusColor(c.status);
    return ComplaintCardWidget(
      complaint: c,
      index: index,
      statusColor: statusColor,
      statusIcon: _statusIcon(c.status),
      onTap: () => _showComplaintDetails(c),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: UserComplaintsHeader(onBack: () => Get.back()),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const CenteredLoading();
                }
                final list = _controller.complaints;
                if (list.isEmpty) {
                  return RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    onRefresh: _load,
                    child: const EmptyComplaintsView(),
                  );
                }
                return RefreshIndicator(
                  color: Theme.of(context).primaryColor,
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

class CenteredLoading extends StatelessWidget {
  const CenteredLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
    );
  }
}
