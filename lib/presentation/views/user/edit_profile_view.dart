import 'dart:io';
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
                        border: Border.all(
                          color: AppColors.main,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: selectedImage != null
                            ? Image.file(
                          selectedImage,
                          fit: BoxFit.cover,
                        )
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
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
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
            const SizedBox(height: 32),

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