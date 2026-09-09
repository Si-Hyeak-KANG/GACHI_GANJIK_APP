import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import '../../widgets/common/account_link_dialog.dart';
import 'auth_controller.dart';

enum SignupStep { emailVerification, userInfo, complete }

class SignupController extends GetxController {
  final AuthRepository _authRepository;

  SignupController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ─────────────────────────────────────────
  // Step 상태
  // ─────────────────────────────────────────
  final Rx<SignupStep> currentStep = SignupStep.emailVerification.obs;

  // ─────────────────────────────────────────
  // STEP 1 - 이메일 인증
  // ─────────────────────────────────────────
  final emailController = TextEditingController();
  final verificationCodeController = TextEditingController();

  final RxBool isCodeSent = false.obs;
  final RxBool isEmailVerified = false.obs;
  final RxBool isSendingCode = false.obs;
  final RxBool isVerifyingCode = false.obs;
  final RxString emailText = ''.obs;
  final RxString codeText = ''.obs;

  // 재발송 쿨다운 (60초)
  final RxInt resendCooldown = 0.obs;
  bool get canResend => resendCooldown.value == 0;

  // 코드 만료 카운트다운 (180초)
  final RxInt codeExpireCountdown = 0.obs;
  bool get isCodeExpired => isCodeSent.value && codeExpireCountdown.value == 0;

  Timer? _resendTimer;
  Timer? _expireTimer;
  // ─────────────────────────────────────────
  // STEP 2 - 사용자 정보 입력
  // ─────────────────────────────────────────
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscurePasswordConfirm = true.obs;

  // userInfo 내 현재 활성 필드 인덱스 (0: 닉네임, 1: 비밀번호, 2: 비밀번호 확인)
  final RxInt userInfoPhase = 0.obs;

  // ─────────────────────────────────────────
  // 공통
  // ─────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_onEmailChanged);
    verificationCodeController.addListener(_onCodeChanged);
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    _expireTimer?.cancel();
    emailController.removeListener(_onEmailChanged);
    verificationCodeController.removeListener(_onCodeChanged);
    emailController.dispose();
    verificationCodeController.dispose();
    nicknameController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.onClose();
  }

  void _onEmailChanged() => emailText.value = emailController.text;
  void _onCodeChanged() => codeText.value = verificationCodeController.text;

  // ─────────────────────────────────────────
  // STEP 1 액션
  // ─────────────────────────────────────────

  String? _validateEmail(String email) {
    if (email.isEmpty) return '이메일을 입력해주세요';
    if (!GetUtils.isEmail(email)) return '올바른 이메일 형식이 아닙니다';
    return null;
  }

  Future<void> sendVerificationCode() async {
    if (!canResend) return;
    final email = emailController.text.trim();
    final error = _validateEmail(email);
    if (error != null) {
      errorMessage.value = error;
      return;
    }
    errorMessage.value = '';
    isSendingCode.value = true;
    try {
      await _authRepository.sendVerificationCode(email);

      // 재발송 시 기존 코드 만료 처리
      _expireTimer?.cancel();
      verificationCodeController.clear();

      isCodeSent.value = true;
      _startResendCooldown();
      _startExpireCountdown();
    } on NetworkException catch (e) {
      // 이미 이메일 로그인 수단이 있는 순수 중복 → 인라인 안내만 (자동 이동 안 함)
      if (e.errorCode == 'EMAIL_ALREADY_EXISTS') {
        errorMessage.value = '이미 가입된 이메일입니다. 기존 방식으로 로그인해주세요.';
        return;
      }
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = '인증코드 발송에 실패했습니다';
    } finally {
      isSendingCode.value = false;
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    resendCooldown.value = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendCooldown.value <= 0) {
        t.cancel();
      } else {
        resendCooldown.value--;
      }
    });
  }

  void _startExpireCountdown() {
    _expireTimer?.cancel();
    codeExpireCountdown.value = 180;
    _expireTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (codeExpireCountdown.value <= 0) {
        t.cancel();
        // 만료 시 에러 메시지 표시 (코드 입력 중인 경우 안내)
        if (isCodeSent.value && !isEmailVerified.value) {
          errorMessage.value = '인증코드가 만료되었습니다. 재발송해주세요.';
        }
      } else {
        codeExpireCountdown.value--;
      }
    });
  }

  Future<void> verifyCode() async {
    final code = verificationCodeController.text.trim();
    if (code.isEmpty) {
      errorMessage.value = '인증코드를 입력해주세요';
      return;
    }
    errorMessage.value = '';
    isVerifyingCode.value = true;
    try {
      await _authRepository.verifyEmailCode(emailController.text.trim(), code);
      isEmailVerified.value = true;
      currentStep.value = SignupStep.userInfo;
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = '인증코드가 올바르지 않습니다';
    } finally {
      isVerifyingCode.value = false;
    }
  }

  // ─────────────────────────────────────────
  // STEP 2 액션
  // ─────────────────────────────────────────

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void togglePasswordConfirmVisibility() =>
      obscurePasswordConfirm.value = !obscurePasswordConfirm.value;

  String? validateNickname(String value) {
    if (value.isEmpty) return '이름을 입력해주세요';
    if (value.length < 2) return '2자 이상 입력해주세요';
    if (value.length > 20) return '20자 이하로 입력해주세요';
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return '비밀번호를 입력해주세요';
    if (value.length < 8) return '8자 이상 입력해주세요';
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);
    if (!hasLetter || !hasDigit || !hasSpecial) return '영문, 숫자, 특수문자를 모두 포함해주세요';
    return null;
  }

  String? validatePasswordConfirm(String value) {
    if (value.isEmpty) return '비밀번호를 다시 입력해주세요';
    if (value != passwordController.text) return '비밀번호가 일치하지 않습니다';
    return null;
  }

  /// 닉네임 완료 → 비밀번호 입력란 노출
  void confirmNickname() {
    final error = validateNickname(nicknameController.text.trim());
    if (error != null) {
      errorMessage.value = error;
      return;
    }
    errorMessage.value = '';
    userInfoPhase.value = 1;
  }

  /// 비밀번호 완료 → 비밀번호 확인 입력란 노출
  void confirmPassword() {
    final error = validatePassword(passwordController.text);
    if (error != null) {
      errorMessage.value = error;
      return;
    }
    errorMessage.value = '';
    userInfoPhase.value = 2;
  }

  /// 완료된 비밀번호를 다시 수정 (비밀번호 확인 초기화 후 입력 단계로 되돌림)
  void editPassword() {
    errorMessage.value = '';
    passwordConfirmController.clear();
    userInfoPhase.value = 1;
  }

  /// 완료된 닉네임을 다시 수정
  void editNickname() {
    errorMessage.value = '';
    userInfoPhase.value = 0;
  }

  /// 비밀번호 확인 완료 → 회원가입 API 호출
  Future<void> confirmPasswordAndSignup() async {
    final error = validatePasswordConfirm(passwordConfirmController.text);
    if (error != null) {
      errorMessage.value = error;
      return;
    }
    errorMessage.value = '';
    await _signup();
  }

  Future<void> _signup() async {
    isLoading.value = true;
    try {
      final outcome = await _authRepository.signup(
        emailController.text.trim(),
        passwordController.text,
        nicknameController.text.trim(),
      );
      if (outcome.needsLink) {
        // 동일 이메일이 다른 로그인 수단으로 이미 가입됨 → 연동 확인
        showAccountLinkDialog(
          maskedEmail: outcome.maskedEmail,
          onLink: () => _linkEmail(outcome.linkTicket!),
          onGoLogin: _goToLogin,
        );
      } else {
        Get.find<AuthController>().onLoginSuccess(outcome.user!);
        currentStep.value = SignupStep.complete;
      }
    } on NetworkException catch (e) {
      // 이미 이메일 로그인 수단이 있는 순수 중복 → 인라인 안내만 (자동 이동 안 함)
      if (e.errorCode == 'EMAIL_ALREADY_EXISTS') {
        errorMessage.value = '이미 가입된 이메일입니다.';
        return;
      }
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = '알 수 없는 오류가 발생했습니다';
    } finally {
      isLoading.value = false;
    }
  }

  // 기존 계정에 이메일/비밀번호 수단 연동 (사용자가 입력한 비밀번호 재전송)
  Future<void> _linkEmail(String linkTicket) async {
    isLoading.value = true;
    try {
      final user = await _authRepository.linkEmailAccount(
        linkTicket: linkTicket,
        password: passwordController.text,
      );
      Get.find<AuthController>().onLoginSuccess(user);
      currentStep.value = SignupStep.complete;
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = '계정 연동에 실패했습니다';
    } finally {
      isLoading.value = false;
    }
  }

  void _goToLogin() => Get.offAllNamed(Routes.login);

  // ─────────────────────────────────────────
  // STEP 3 액션
  // ─────────────────────────────────────────

  void goToHome() {
    Get.offAllNamed(Routes.home);
  }
}