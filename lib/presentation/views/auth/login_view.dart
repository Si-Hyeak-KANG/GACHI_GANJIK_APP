import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/auth/login_controller.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  LoginController get _controller => Get.find<LoginController>();

  void _showEmailLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmailLoginSheet(controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F9FC),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── 로고 영역 (화면 중앙 확장) ──────────────────────────
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 220,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '같이간직',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '소중한 순간을 함께 간직하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 소셜 버튼 + 텍스트 링크 (하단 고정) ─────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => _SocialLoginButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google로 계속하기',
                          onTap: _controller.isLoading.value
                              ? null
                              : _controller.googleLogin,
                          iconColor: Colors.red,
                        )),
                    const SizedBox(height: 14),
                    _SocialLoginButton(
                      label: 'Kakao로 계속하기',
                      onTap: null,
                      isComingSoon: true,
                      iconColor: const Color(0xFF3C1E1E),
                      icon: Icons.chat_bubble,
                    ),
                    const SizedBox(height: 14),
                    _SocialLoginButton(
                      label: 'Apple로 계속하기',
                      onTap: null,
                      isComingSoon: true,
                      iconColor: Colors.black,
                      icon: Icons.apple,
                    ),
                    const SizedBox(height: 14),
                    // 회원가입 없이 시작하기
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.guestEntry),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: const Text(
                          '회원가입 없이 시작하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showEmailLoginSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFEAEAEA),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.mail_outline_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '다른 방법으로 로그인',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 이메일 로그인 바텀 시트 ──────────────────────────────────────────
class _EmailLoginSheet extends StatefulWidget {
  final LoginController controller;

  const _EmailLoginSheet({required this.controller});

  @override
  State<_EmailLoginSheet> createState() => _EmailLoginSheetState();
}

class _EmailLoginSheetState extends State<_EmailLoginSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들바
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inactive,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child: Column(
                  children: const [
                    Text(
                      '이메일 로그인',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '이메일과 비밀번호를 입력해주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      label: '이메일',
                      hint: 'email@example.com',
                      controller: _emailController,
                      validator: widget.controller.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => CustomTextField(
                        label: '비밀번호',
                        hint: '비밀번호를 입력해주세요',
                        controller: _passwordController,
                        validator: widget.controller.validatePassword,
                        obscureText: widget.controller.obscurePassword.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            widget.controller.obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.inactive,
                            size: 20,
                          ),
                          onPressed: widget.controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Obx(() => CustomButton(
                    text: '로그인',
                    isLoading: widget.controller.isLoading.value,
                    onTap: () => widget.controller.emailLogin(
                      formKey: _formKey,
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                    ),
                  )),
              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.signup);
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: '계정이 없으신가요? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: '회원가입',
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 소셜 로그인 버튼 ────────────────────────────────────────────────
class _SocialLoginButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData icon;
  final Color iconColor;
  final bool isComingSoon;

  const _SocialLoginButton({
    required this.label,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isComingSoon ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isComingSoon
                  ? const Color(0xFFF0F0F0)
                  : const Color(0xFFE8E8E8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: iconColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isComingSoon
                            ? AppColors.inactive
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              if (isComingSoon)
                const Positioned(
                  right: 16,
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.main,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
