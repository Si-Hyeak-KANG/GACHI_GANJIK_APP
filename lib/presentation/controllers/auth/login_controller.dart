import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import '../../widgets/common/account_link_dialog.dart';
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
      Get.snackbar('로그인 실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('오류', '알 수 없는 오류가 발생했습니다', snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> googleLogin() =>
      _socialLogin(_authRepository.googleLogin, 'Google');
  Future<void> kakaoLogin() =>
      _socialLogin(_authRepository.kakaoLogin, 'Kakao');
  Future<void> naverLogin() =>
      _socialLogin(_authRepository.naverLogin, 'Naver');

  // 소셜 로그인 공통 처리
  Future<void> _socialLogin(
      Future<SocialLoginOutcome> Function() login, String providerLabel) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final outcome = await login();
      if (outcome.needsOnboarding) {
        // 신규 사용자 → 닉네임 온보딩
        Get.toNamed(Routes.socialOnboarding, arguments: {
          'signupTicket': outcome.signupTicket,
          'suggestedNickname': outcome.suggestedNickname,
          'provider': providerLabel,
        });
      } else if (outcome.needsLink) {
        // 동일 이메일 기존 계정 존재 → 연동 확인
        _promptLink(outcome.linkTicket!, outcome.maskedEmail);
      } else {
        Get.find<AuthController>().onLoginSuccess(outcome.user!);
        Get.offAllNamed(Routes.home);
      }
    } on SocialLoginCancelledException {
      // 사용자가 로그인 창을 취소함 → 에러 표시 없이 조용히 무시
    } on NetworkException catch (e) {
      debugPrint('[$providerLabel] 소셜 로그인 네트워크 오류: ${e.errorCode} ${e.message}');
      Get.snackbar('로그인 실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e, st) {
      // 원인 파악용 로그 (이전 "로그 안 찍힘" 문제 방지)
      debugPrint('[$providerLabel] 소셜 로그인 실패: $e\n$st');
      Get.snackbar('로그인 실패', '로그인을 완료하지 못했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void _promptLink(String linkTicket, String? maskedEmail) {
    showAccountLinkDialog(
      maskedEmail: maskedEmail,
      onLink: () => _linkSocial(linkTicket),
      onGoLogin: () => Get.snackbar('안내', '기존 방식으로 로그인해주세요',
          snackPosition: SnackPosition.BOTTOM),
    );
  }

  Future<void> _linkSocial(String linkTicket) async {
    isLoading.value = true;
    try {
      final user = await _authRepository.linkSocialAccount(linkTicket: linkTicket);
      Get.find<AuthController>().onLoginSuccess(user);
      Get.offAllNamed(Routes.home);
    } on NetworkException catch (e) {
      Get.snackbar('연동 실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e, st) {
      debugPrint('소셜 연동 실패: $e\n$st');
      Get.snackbar('연동 실패', '계정 연동에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
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