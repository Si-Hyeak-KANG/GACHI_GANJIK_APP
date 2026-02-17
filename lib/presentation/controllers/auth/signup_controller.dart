import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import 'auth_controller.dart';

class SignupController extends GetxController {
  final AuthRepository _authRepository;

  SignupController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscurePasswordConfirm = true.obs;

  @override
  void onClose() {
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void togglePasswordConfirmVisibility() =>
      obscurePasswordConfirm.value = !obscurePasswordConfirm.value;

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final user = await _authRepository.signup(
        emailController.text.trim(),
        passwordController.text,
        nicknameController.text.trim(),
      );

      Get.find<AuthController>().onLoginSuccess(user);
      Get.offAllNamed(Routes.home);
    } on NetworkException catch (e) {
      Get.snackbar(
        '가입 실패',
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

  String? validateNickname(String? value) {
    if (value == null || value.isEmpty) return '닉네임을 입력해주세요';
    if (value.length < 2) return '닉네임은 2자 이상이어야 합니다';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return '이메일을 입력해주세요';
    if (!GetUtils.isEmail(value)) return '올바른 이메일 형식이 아닙니다';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return '비밀번호를 입력해주세요';
    if (value.length < 4) return '비밀번호는 4자 이상이어야 합니다';
    return null;
  }

  String? validatePasswordConfirm(String? value) {
    if (value == null || value.isEmpty) return '비밀번호를 한번 더 입력해주세요';
    if (value != passwordController.text) return '비밀번호가 일치하지 않습니다';
    return null;
  }
}