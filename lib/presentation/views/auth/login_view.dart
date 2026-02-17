import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/auth/login_controller.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // 헤더
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_album_rounded,
                        size: 56,
                        color: AppColors.main,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '같이간직에 오신 것을 환영해요',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 소셜 로그인
                Obx(() => _SocialLoginButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Google로 계속하기',
                  onTap: controller.isLoading.value
                      ? null
                      : controller.googleLogin,
                  iconColor: Colors.red,
                )),
                const SizedBox(height: 12),

                // 비활성 소셜 버튼들
                _SocialLoginButton(
                  label: 'Kakao로 계속하기',
                  onTap: null,
                  isComingSoon: true,
                  iconColor: const Color(0xFF3C1E1E),
                  icon: Icons.chat_bubble,
                ),
                const SizedBox(height: 12),
                _SocialLoginButton(
                  label: 'Apple로 계속하기',
                  onTap: null,
                  isComingSoon: true,
                  iconColor: Colors.black,
                  icon: Icons.apple,
                ),

                // 구분선
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFF0F0F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '또는',
                          style: TextStyle(
                            color: AppColors.inactive,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFF0F0F0))),
                    ],
                  ),
                ),

                // 이메일 입력
                CustomTextField(
                  label: '이메일',
                  hint: 'email@example.com',
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력
                Obx(() => CustomTextField(
                  label: '비밀번호',
                  hint: '비밀번호를 입력해주세요',
                  controller: controller.passwordController,
                  validator: controller.validatePassword,
                  obscureText: controller.obscurePassword.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.inactive,
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                )),
                const SizedBox(height: 32),

                // 로그인 버튼
                Obx(() => CustomButton(
                  text: '로그인',
                  isLoading: controller.isLoading.value,
                  onTap: controller.emailLogin,
                )),
                const SizedBox(height: 16),

                // 회원가입 이동
                Center(
                  child: GestureDetector(
                    onTap: () => Get.toNamed(Routes.signup),
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

                // 테스트 안내 (개발 중에만 표시)
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mainLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🧪 테스트 계정',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.main,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Email: test@test.com\nPW: 1234',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 소셜 로그인 버튼 위젯
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isComingSoon
                  ? const Color(0xFFF0F0F0)
                  : const Color(0xFFE8E8E8),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isComingSoon
                          ? AppColors.inactive
                          : AppColors.textPrimary,
                    ),
                  ),
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