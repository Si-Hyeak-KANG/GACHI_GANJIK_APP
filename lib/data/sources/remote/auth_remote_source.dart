import '../../models/auth/auth_response.dart';
import '../../models/auth/email_signup_response.dart';
import '../../models/auth/social_auth_response.dart';
import '../../models/auth/login_request.dart';
import '../../models/auth/signup_request.dart';

abstract class AuthRemoteSource {
  Future<AuthResponse> emailLogin(LoginRequest request);

  // 소셜 로그인: 기존 / 이메일 연동 필요 / 신규 (SocialAuthResponse 3-state)
  Future<SocialAuthResponse> googleLogin(String idToken);
  Future<SocialAuthResponse> kakaoLogin(String accessToken);
  Future<SocialAuthResponse> naverLogin(String accessToken);

  // 신규 소셜 사용자 온보딩 완료 (닉네임만) → 계정 생성/로그인
  Future<AuthResponse> socialSignupComplete({
    required String signupTicket,
    required String nickname,
  });

  // 기존 계정에 소셜 로그인 수단 연결
  Future<AuthResponse> socialLink({required String linkTicket});

  // 기존 계정에 이메일/비밀번호 로그인 수단 연결
  Future<AuthResponse> emailLink({
    required String linkTicket,
    required String password,
  });

  // 이메일 회원가입 → 생성 또는 이메일 연동 필요
  Future<EmailSignupResponse> signup(SignupRequest request);

  Future<void> logout();
  Future<void> sendVerificationCode(String email);
  Future<void> verifyEmailCode(String email, String code);
}