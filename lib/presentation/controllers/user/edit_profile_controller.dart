import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/network/network_exception.dart';
import '../user/user_controller.dart';

class EditProfileController extends GetxController {
  final UserRepository _userRepository;

  EditProfileController({required UserRepository userRepository})
      : _userRepository = userRepository;

  final nicknameController = TextEditingController();
  final Rxn<File> selectedImage = Rxn<File>();
  final RxBool isLoading = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // 현재 닉네임으로 초기화
    final userController = Get.find<UserController>();
    nicknameController.text = userController.user.value?.nickname ?? '';
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }

  // 프로필 사진 선택
  Future<void> pickProfileImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // 저장
  Future<void> saveProfile() async {
    final nickname = nicknameController.text.trim();

    if (nickname.isEmpty) {
      Get.snackbar('알림', '닉네임을 입력해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (nickname.length < 2) {
      Get.snackbar('알림', '닉네임은 2자 이상이어야 합니다',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final updatedUser = await _userRepository.updateProfile(
        nickname: nickname,
        profileImage: selectedImage.value,
      );

      // UserController 업데이트
      Get.find<UserController>().updateUser(updatedUser);

      Get.back();
      Get.snackbar(
        '완료',
        '프로필이 업데이트되었습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) return '닉네임을 입력해주세요';
    if (value.trim().length < 2) return '닉네임은 2자 이상이어야 합니다';
    return null;
  }
}