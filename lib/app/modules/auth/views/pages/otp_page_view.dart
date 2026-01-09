import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/verify_otp_controller.dart';
import 'package:goverment_complaints/app/modules/auth/models/request/otp_request_model.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/auth_logo.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/otp_count_down.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/otp_fields.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/otp_header.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/otp_resend_button.dart';
import 'package:goverment_complaints/app/modules/auth/views/widgets/otp_verify_button.dart';
import 'package:goverment_complaints/app/routes/app_routes.dart';

class OTPVerificationView extends StatefulWidget {
  const OTPVerificationView({super.key});

  @override
  State<OTPVerificationView> createState() => _OTPVerificationViewState();
}

class _OTPVerificationViewState extends State<OTPVerificationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _countdown = 60;
  bool _canResend = false;
  late final VerifyOtpController _controller;
  late final int _citizenId;

  @override
  void initState() {
    super.initState();

    _controller = Get.find<VerifyOtpController>();

    final args = Get.arguments ?? {};
    final dynamic rawId = args['citizen_id'];
    _citizenId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    _startCountdown();

    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        if (_controllers[i].text.isEmpty && i > 0) {
          _focusNodes[i - 1].requestFocus();
        }
        setState(() {});
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
          _startCountdown();
        } else {
          _canResend = true;
        }
      });
    });
  }

  Future<void> _resendOTP() async {
    if (_citizenId == 0) {
      Get.snackbar(
        'error'.tr,
        'citizen_id_missing_resend'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _countdown = 60;
      _canResend = false;
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    });

    // // أنادي الكونترولر لإعادة الإرسال
    // final ok = await _controller.resendOtp(_citizenId);
    // if (ok) {
    //   // إعادة تشغيل العدّاد
    //   _startCountdown();
    //   _animationController.reset();
    //   _animationController.forward();
    // } else {
    //   // إذا فشل أسمح بإعادة المحاولة على الفور أو بعد رسالة
    //   setState(() {
    //     _canResend = true;
    //   });
    // }
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((c) => c.text.trim()).join();
    if (otp.length != 6) {
      Get.snackbar(
        'error'.tr,
        'enter_6_digits'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_citizenId == 0) {
      Get.snackbar(
        'error'.tr,
        'citizen_id_missing'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final req = VerifyOtpRequest(otp: otp, citizenId: _citizenId);
    final resp = await _controller.verifyOtp(req);

    if (resp != null && resp.status.toLowerCase() == 'success') {
      Get.snackbar(
        'done'.tr,
        resp.message,
        backgroundColor: Color(0xFFb9a779),
        colorText: Colors.white,
      );
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.snackbar(
        'failed'.tr,
        resp?.message ?? 'verification_failed'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),

                    AuthLogo(),

                    SizedBox(height: 30.h),

                    OTPHeader(),

                    SizedBox(height: 40.h),

                    OtpFields(
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      onComplete: _verifyOTP,
                    ),

                    SizedBox(height: 30.h),

                    Obx(() {
                      final isLoading = _controller.isLoading.value;
                      return OtpVerifyButton(
                        isLoading: isLoading,
                        onPressed: _verifyOTP,
                      );
                    }),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
