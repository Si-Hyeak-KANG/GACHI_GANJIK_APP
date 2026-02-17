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

  // Form 관련
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 상태
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    // 화면 종료 시 TextEditingController 해제
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // 비밀번호 보기/숨기기 토글
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // 이메일 로그인
  Future<void> emailLogin() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final user = await _authRepository.emailLogin(
        emailController.text.trim(),
        passwordController.text,
      );

      // 전역 AuthController 상태 업데이트
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
      isLoading.value = false;
    }
  }

  // Google 로그인
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
      isLoading.value = false;
    }
  }

  // 이메일 유효성 검사
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!GetUtils.isEmail(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  // 비밀번호 유효성 검사
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 4) {
      return '비밀번호는 4자 이상이어야 합니다';
    }
    return null;
  }
}