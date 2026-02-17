import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/auth/signup_controller.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '간단한 정보를 입력해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // 닉네임
                CustomTextField(
                  label: '닉네임',
                  hint: '닉네임을 입력해주세요',
                  controller: controller.nicknameController,
                  validator: controller.validateNickname,
                  isRequired: true,
                ),
                const SizedBox(height: 20),

                // 이메일
                CustomTextField(
                  label: '이메일',
                  hint: 'email@example.com',
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                ),
                const SizedBox(height: 20),

                // 비밀번호
                Obx(() => CustomTextField(
                  label: '비밀번호',
                  hint: '4자 이상 입력해주세요',
                  controller: controller.passwordController,
                  validator: controller.validatePassword,
                  obscureText: controller.obscurePassword.value,
                  isRequired: true,
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
                const SizedBox(height: 20),

                // 비밀번호 확인
                Obx(() => CustomTextField(
                  label: '비밀번호 확인',
                  hint: '비밀번호를 다시 입력해주세요',
                  controller: controller.passwordConfirmController,
                  validator: controller.validatePasswordConfirm,
                  obscureText: controller.obscurePasswordConfirm.value,
                  isRequired: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscurePasswordConfirm.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.inactive,
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordConfirmVisibility,
                  ),
                )),
                const SizedBox(height: 40),

                // 가입 버튼
                Obx(() => CustomButton(
                  text: '가입하기',
                  isLoading: controller.isLoading.value,
                  onTap: controller.signup,
                )),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}