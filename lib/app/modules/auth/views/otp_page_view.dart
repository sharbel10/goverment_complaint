import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/auth/views/complaints_page_view.dart';

class OTPVerificationView extends StatefulWidget {
  const OTPVerificationView({super.key});

  @override
  State<OTPVerificationView> createState() => _OTPVerificationViewState();
}

class _OTPVerificationViewState extends State<OTPVerificationView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
    _startCountdown();

    // إضافة مستمعين للحقول
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        if (_controllers[i].text.isEmpty && i > 0) {
          _focusNodes[i - 1].requestFocus();
        }
      });
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
            _startCountdown();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  void _resendOTP() {
    setState(() {
      _countdown = 60;
      _canResend = false;
      // مسح جميع الحقول
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    });
    _startCountdown();

    // أنيميشن عند إعادة الإرسال
    _animationController.reset();
    _animationController.forward();
  }

  void _verifyOTP() {
    Get.to(HomeView());
    // String otp = _controllers.map((controller) => controller.text).join();
    // if (otp.length == 6) {
    //   // هنا تكتب منطق التحقق من OTP
    //   Get.rawSnackbar(
    //     messageText: const Text(
    //       "جاري التحقق من الرمز...",
    //       style: TextStyle(color: Color(0xFFedebe0)),
    //     ),
    //     backgroundColor: const Color(0xFF002623),
    //     borderColor: const Color(0xFFb9a779),
    //   );
    // }
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
                    Row(
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
                              color: _controllers[index].text.isEmpty
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
                            onChanged: (value) {
                              setState(() {});
                              if (value.isNotEmpty && index == 5) {
                                _verifyOTP();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),

                    /// Countdown Timer
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _canResend
                          ? Column(
                        children: [
                          const Text(
                            "لم تستلم الرمز؟",
                            style: TextStyle(
                              color: Color(0xFFedebe0),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Resend Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _resendOTP,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFb9a779),
                                side: const BorderSide(
                                  color: Color(0xFFb9a779),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "إعادة إرسال الرمز",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFb9a779),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "إعادة الإرسال خلال ",
                            style: TextStyle(
                              color: Color(0xFFedebe0),
                              fontSize: 16,
                            ),
                          ),
                          TweenAnimationBuilder(
                            duration: Duration(seconds: _countdown),
                            tween: Tween(begin: _countdown.toDouble(), end: 0.0),
                            builder: (context, value, child) {
                              return Text(
                                "${value.toInt()} ثانية",
                                style: const TextStyle(
                                  color: Color(0xFFb9a779),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFb9a779),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFFb9a779).withOpacity(0.5),
                        ),
                        child: const Text(
                          "تحقق",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Back to Login
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "العودة لتسجيل الدخول",
                        style: TextStyle(
                          color: Color(0xFFb9a779),
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFb9a779),
                        ),
                      ),
                    ),

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