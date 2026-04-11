import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository;

  LoginController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // formKey, email, password를 View에서 직접 전달받음
  // TextEditingController는 View(StatefulWidget)에서 관리
  Future<void> emailLogin({
    required GlobalKey<FormState> formKey,
    required String email,
    required String password,
  }) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final user = await _authRepository.emailLogin(email, password);
      Get.find<AuthController>().onLoginSuccess(user);
      Get.offAllNamed(Routes.home);
    } on NetworkException catch (e) {
      Get.snackbar(
        '로그인 실패',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '알 수 없는 오류가 발생했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> googleLogin() async {
    isLoading.value = true;

    try {
      final user = await _authRepository.googleLogin();
      Get.find<AuthController>().onLoginSuccess(user);
      Get.offAllNamed(Routes.home);
    } on NetworkException catch (e) {
      Get.snackbar(
        '로그인 실패',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return '이메일을 입력해주세요';
    if (!GetUtils.isEmail(value)) return '올바른 이메일 형식이 아닙니다';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return '비밀번호를 입력해주세요';
    if (value.length < 8) return '비밀번호는 8자 이상이어야 합니다';
    return null;
  }
}
