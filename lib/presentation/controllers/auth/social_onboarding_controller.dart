import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_controller.dart';

/// 신규 소셜 사용자 온보딩 — 닉네임만 입력받아 가입 완료.
/// (휴대폰 인증은 정책상 제거됨)
class SocialOnboardingController extends GetxController {
  final AuthRepository _authRepository;

  SocialOnboardingController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final nicknameController = TextEditingController();

  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  late final String _signupTicket;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    _signupTicket = (args?['signupTicket'] as String?) ?? '';
    final suggested = args?['suggestedNickname'] as String?;
    if (suggested != null && suggested.isNotEmpty) {
      nicknameController.text = suggested;
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }

  String? validateNickname(String value) {
    final v = value.trim();
    if (v.isEmpty) return '이름을 입력해주세요';
    if (v.length < 2) return '2자 이상 입력해주세요';
    if (v.length > 20) return '20자 이하로 입력해주세요';
    return null;
  }

  Future<void> submit() async {
    final nickErr = validateNickname(nicknameController.text);
    if (nickErr != null) {
      errorMessage.value = nickErr;
      return;
    }
    errorMessage.value = '';
    isSubmitting.value = true;
    try {
      final user = await _authRepository.completeSocialSignup(
        signupTicket: _signupTicket,
        nickname: nicknameController.text.trim(),
      );
      _finish(user);
    } on NetworkException catch (e) {
      if (_isTicketExpired(e)) return;
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = '가입을 완료하지 못했습니다';
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  // 티켓 만료/소진 → 소셜 로그인부터 재시작 (로그인 화면)
  bool _isTicketExpired(NetworkException e) {
    if (e.errorCode == 'SIGNUP_TICKET_NOT_FOUND') {
      Get.snackbar('세션 만료', '소셜 로그인부터 다시 시도해주세요',
          snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed(Routes.login);
      return true;
    }
    return false;
  }

  void _finish(User user) {
    Get.find<AuthController>().onLoginSuccess(user);
    Get.offAllNamed(Routes.home);
  }
}