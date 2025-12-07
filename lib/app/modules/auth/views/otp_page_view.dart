import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/auth/controllers/verify_otp_controller.dart';
import 'package:goverment_complaints/app/modules/auth/models/request/otp_request_model.dart';
import 'package:goverment_complaints/app/modules/complaints/views/create_complaints_page_view.dart';

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
        'خطأ',
        'معرّف المواطن غير موجود لإعادة الإرسال',
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
        'خطأ',
        'الرجاء إدخال رمز مكون من 6 أرقام',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_citizenId == 0) {
      Get.snackbar(
        'خطأ',
        'معرّف المواطن غير موجود',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final req = VerifyOtpRequest(otp: otp, citizenId: _citizenId);
    final resp = await _controller.verifyOtp(req);

    if (resp != null && resp.status.toLowerCase() == 'success') {
      Get.snackbar(
        'تم',
        resp.message,
        backgroundColor: Color(0xFFb9a779),
        colorText: Colors.white,
      );
      // انتقل للصفحة الرئيسية (استبدل ComplaintsPageView إذا الصفحة الأساسية مختلفة)
      Get.offAll(() => const HomeView());
    } else {
      Get.snackbar(
        'فشل',
        resp?.message ?? 'فشل التحقق',
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

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF003832),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _controllers[index].text.isEmpty
                      ? const Color(0xFFb9a779).withOpacity(0.3)
                      : const Color(0xFFb9a779),
              width: 2,
            ),
            boxShadow: [
              if (_controllers[index].text.isNotEmpty)
                BoxShadow(
                  color: const Color(0xFFb9a779).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFedebe0),
            ),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) async {
              // إذا وصلنا للحرف السادس وملأناه نحقق تلقائيًا
              if (value.isNotEmpty && index == 5) {
                await Future.delayed(const Duration(milliseconds: 100));
                _verifyOTP();
              }
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002623),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    /// LOGO
                    Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/syrian-republic-logo-png_seeklogo-622502.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "التحقق من الرمز",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFb9a779),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      "أدخل الرمز المكون من 6 أرقام المرسل إلى هاتفك",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFFedebe0)),
                    ),

                    const SizedBox(height: 40),

                    /// OTP Fields
                    _buildOtpFields(),

                    const SizedBox(height: 30),

                    /// Countdown & Resend
                    // Obx(() {
                    //   final resendLoading = _controller.resendLoading.value;
                    //   if (_canResend) {
                    //     return Column(
                    //       children: [
                    //         const Text(
                    //           "لم تستلم الرمز؟",
                    //           style: TextStyle(
                    //             color: Color(0xFFedebe0),
                    //             fontSize: 16,
                    //           ),
                    //         ),
                    //         const SizedBox(height: 8),
                    //         SizedBox(
                    //           width: double.infinity,
                    //           height: 52,
                    //           child: OutlinedButton(
                    //             onPressed: resendLoading ? null : _resendOTP,
                    //             style: OutlinedButton.styleFrom(
                    //               foregroundColor: const Color(0xFFb9a779),
                    //               side: const BorderSide(
                    //                 color: Color(0xFFb9a779),
                    //                 width: 2,
                    //               ),
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(14),
                    //               ),
                    //             ),
                    //             child:
                    //                 resendLoading
                    //                     ? const CircularProgressIndicator()
                    //                     : const Text(
                    //                       "إعادة إرسال الرمز",
                    //                       style: TextStyle(
                    //                         fontSize: 16,
                    //                         fontWeight: FontWeight.w600,
                    //                         color: Color(0xFFb9a779),
                    //                       ),
                    //                     ),
                    //           ),
                    //         ),
                    //       ],
                    //     );
                    //   } else {
                    //     return Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         const Text(
                    //           "إعادة الإرسال خلال ",
                    //           style: TextStyle(
                    //             color: Color(0xFFedebe0),
                    //             fontSize: 16,
                    //           ),
                    //         ),
                    //         Text(
                    //           "$_countdown ثانية",
                    //           style: const TextStyle(
                    //             color: Color(0xFFb9a779),
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ],
                    //     );
                    //   }
                    // }),

                    // const SizedBox(height: 30),

                    // /// Verify Button
                    Obx(() {
                      final isLoading = _controller.isLoading.value;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFb9a779),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: const Color(
                              0xFFb9a779,
                            ).withOpacity(0.5),
                          ),
                          child:
                              isLoading
                                  ? const CircularProgressIndicator(
                                    color: Color(0xFFb9a779),
                                  )
                                  : const Text(
                                    "تحقق",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
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
