import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/auth/signup_controller.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Obx(() {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (controller.currentStep.value) {
              SignupStep.emailVerification => const _EmailVerificationStep(
                  key: ValueKey('email'),
                ),
              SignupStep.userInfo => const _UserInfoStep(
                  key: ValueKey('userInfo'),
                ),
              SignupStep.complete => const _CompleteStep(
                  key: ValueKey('complete'),
                ),
            },
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 공통 레이아웃
// ─────────────────────────────────────────────────────────────

class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.child,
    this.showBack = true,
  });

  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.textPrimary, size: 20),
              onPressed: Get.back,
            ),
          )
        else
          const SizedBox(height: 56),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: child,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 1 - 이메일 인증
// ─────────────────────────────────────────────────────────────

class _EmailVerificationStep extends StatelessWidget {
  const _EmailVerificationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SignupController>();

    return _StepLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          const Text(
            '이메일을 입력해주세요',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '인증 후 계속 진행할 수 있어요',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 64),

          // 이메일 입력 + 인증하기 버튼
          _LabeledField(
            label: '이메일',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(() => _InputField(
                        // ← Obx 추가
                        controller: c.emailController,
                        hint: 'email@example.com',
                        keyboardType: TextInputType.emailAddress,
                        enabled: !c.isCodeSent.value,
                      )),
                ),
                const SizedBox(width: 10),
                Obx(() {
                  final cooldown = c.resendCooldown.value;
                  final sent = c.isCodeSent.value;
                  final hasEmail = c.emailText.value.trim().isNotEmpty;
                  final label = !sent
                      ? '인증하기'
                      : cooldown > 0
                          ? '재발송 ${cooldown}초'
                          : '재발송';
                  // 인증하기: 이메일 1자 이상 입력 시 활성
                  // 재발송: 쿨다운 0일 때만 활성
                  final onTap = sent
                      ? (c.canResend ? c.sendVerificationCode : null)
                      : (hasEmail ? c.sendVerificationCode : null);
                  return _SmallButton(
                    label: label,
                    isLoading: c.isSendingCode.value,
                    onTap: onTap,
                    isDone: sent && !c.canResend,
                  );
                }),
              ],
            ),
          ),

          // 인증코드 입력 (코드 발송 후 노출)
          Obx(() {
            if (!c.isCodeSent.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 34),
                _LabeledField(
                  label: '인증코드',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: c.verificationCodeController,
                              hint: '인증코드 6자리',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(() {
                            final hasCode = c.codeText.value.trim().isNotEmpty;
                            return _SmallButton(
                              label: '확인',
                              isLoading: c.isVerifyingCode.value,
                              onTap: (!c.isCodeExpired && hasCode)
                                  ? c.verifyCode
                                  : null,
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Obx(() {
                        final remaining = c.codeExpireCountdown.value;
                        final mins =
                            (remaining ~/ 60).toString().padLeft(2, '0');
                        final secs =
                            (remaining % 60).toString().padLeft(2, '0');
                        final expired = c.isCodeExpired;
                        return Text(
                          expired ? '인증코드가 만료되었습니다' : '남은 시간  $mins:$secs',
                          style: TextStyle(
                            fontSize: 12,
                            color: expired
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 16),
          Obx(() {
            if (c.errorMessage.value.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                c.errorMessage.value,
                style: const TextStyle(fontSize: 13, color: AppColors.error),
              ),
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 2 - 사용자 정보 입력
// ─────────────────────────────────────────────────────────────

class _UserInfoStep extends StatelessWidget {
  const _UserInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SignupController>();

    return _StepLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
              children: [
                TextSpan(text: '환영합니다.\n\n'),
                TextSpan(
                  text: 'MOWA',
                  style: TextStyle(color: AppColors.main),
                ),
                TextSpan(text: '에서 사용할 \n이름과 비밀번호를 입력해주세요.'),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // 닉네임
          _LabeledField(
            label: '이름',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(() => _InputField(
                        controller: c.nicknameController,
                        hint: '어떻게 불러드릴까요?',
                        enabled: c.userInfoPhase.value == 0,
                      )),
                ),
                const SizedBox(width: 10),
                Obx(() => _SmallButton(
                      label: c.userInfoPhase.value > 0 ? '✓' : '다음',
                      isLoading: false,
                      onTap:
                          c.userInfoPhase.value == 0 ? c.confirmNickname : null,
                      isDone: c.userInfoPhase.value > 0,
                    )),
              ],
            ),
          ),

          // 비밀번호 (닉네임 완료 후 노출)
          Obx(() {
            if (c.userInfoPhase.value < 1) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _LabeledField(
                  label: '비밀번호',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(() => _InputField(
                                  controller: c.passwordController,
                                  hint: '비밀번호를 입력해주세요',
                                  obscureText: c.obscurePassword.value,
                                  enabled: c.userInfoPhase.value == 1,
                                  suffixIcon: c.userInfoPhase.value == 1
                                      ? _VisibilityToggle(
                                          obscure: c.obscurePassword.value,
                                          onTap: c.togglePasswordVisibility,
                                        )
                                      : null,
                                )),
                          ),
                          const SizedBox(width: 10),
                          Obx(() => _SmallButton(
                                label: c.userInfoPhase.value > 1 ? '✓' : '다음',
                                isLoading: false,
                                onTap: c.userInfoPhase.value == 1
                                    ? c.confirmPassword
                                    : null,
                                isDone: c.userInfoPhase.value > 1,
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '8자 이상 · 영문 · 숫자 · 특수문자 포함',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          // 비밀번호 확인 (비밀번호 완료 후 노출)
          Obx(() {
            if (c.userInfoPhase.value < 2) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _LabeledField(
                  label: '비밀번호 확인',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(() => _InputField(
                              controller: c.passwordConfirmController,
                              hint: '비밀번호를 다시 입력해주세요',
                              obscureText: c.obscurePasswordConfirm.value,
                              suffixIcon: _VisibilityToggle(
                                obscure: c.obscurePasswordConfirm.value,
                                onTap: c.togglePasswordConfirmVisibility,
                              ),
                            )),
                      ),
                      const SizedBox(width: 10),
                      Obx(() => _SmallButton(
                            label: '완료',
                            isLoading: c.isLoading.value,
                            onTap: c.confirmPasswordAndSignup,
                          )),
                    ],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 16),
          Obx(() {
            if (c.errorMessage.value.isEmpty) return const SizedBox.shrink();
            return Text(
              c.errorMessage.value,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 3 - 가입 완료
// ─────────────────────────────────────────────────────────────

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SignupController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '가입이 완료되었습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.main,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'MOWA에 오신 것을 환영합니다.\n\n소중한 순간을\n함께 간직해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 64),
          _PrimaryButton(label: '시작하기', onTap: c.goToHome),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 공통 위젯
// ─────────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.inactive,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? AppColors.cardBg : AppColors.divider,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.main, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
    this.isDone = false,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextButton(
        onPressed: isLoading ? null : onTap,
        style: TextButton.styleFrom(
          backgroundColor: isDone ? AppColors.divider : AppColors.main,
          foregroundColor: isDone ? AppColors.textSecondary : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.main,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscure, required this.onTap});

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.inactive,
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}
