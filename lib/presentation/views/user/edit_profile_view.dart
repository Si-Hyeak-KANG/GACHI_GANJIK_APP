import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/user/edit_profile_controller.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          '프로필 편집',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 사진
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final selectedImage = controller.selectedImage.value;
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.main, width: 3),
                      ),
                      child: ClipOval(
                        child: selectedImage != null
                            ? Image.file(selectedImage, fit: BoxFit.cover)
                            : Container(
                          color: AppColors.mainLight,
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.main,
                          ),
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.pickProfileImage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.main,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 닉네임 입력
            CustomTextField(
              controller: controller.nicknameController,
              label: '닉네임',
              hint: '닉네임을 입력해주세요',
              validator: controller.validateNickname,
            ),
            const SizedBox(height: 28),

            // 비밀번호 변경 토글 버튼
            Obx(() => GestureDetector(
              onTap: () => controller.isChangingPassword.value =
              !controller.isChangingPassword.value,
              child: Row(
                children: [
                  const Text(
                    '비밀번호 변경',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    controller.isChangingPassword.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            )),

            // 비밀번호 변경 섹션
            Obx(() => controller.isChangingPassword.value
                ? Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  // 현재 비밀번호
                  Obx(() => CustomTextField(
                    controller: controller.currentPasswordController,
                    label: '현재 비밀번호',
                    hint: '현재 비밀번호를 입력해주세요',
                    obscureText: controller.obscureCurrentPassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureCurrentPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.inactive,
                        size: 20,
                      ),
                      onPressed: () => controller.obscureCurrentPassword
                          .value = !controller.obscureCurrentPassword.value,
                    ),
                  )),
                  const SizedBox(height: 16),

                  // 새 비밀번호
                  Obx(() => CustomTextField(
                    controller: controller.newPasswordController,
                    label: '새 비밀번호',
                    hint: '영문+숫자+특수문자 8~20자',
                    obscureText: controller.obscureNewPassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureNewPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.inactive,
                        size: 20,
                      ),
                      onPressed: () => controller.obscureNewPassword
                          .value = !controller.obscureNewPassword.value,
                    ),
                  )),
                  const SizedBox(height: 16),

                  // 새 비밀번호 확인
                  Obx(() => CustomTextField(
                    controller: controller.passwordConfirmController,
                    label: '새 비밀번호 확인',
                    hint: '새 비밀번호를 다시 입력해주세요',
                    obscureText: controller.obscurePasswordConfirm.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePasswordConfirm.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.inactive,
                        size: 20,
                      ),
                      onPressed: () => controller.obscurePasswordConfirm
                          .value = !controller.obscurePasswordConfirm.value,
                    ),
                  )),
                ],
              ),
            )
                : const SizedBox.shrink()),

            const SizedBox(height: 40),

            // 저장 버튼
            Obx(() => CustomButton(
              text: '저장',
              onTap: controller.saveProfile,
              isLoading: controller.isLoading.value,
            )),
          ],
        ),
      ),
    );
  }
}