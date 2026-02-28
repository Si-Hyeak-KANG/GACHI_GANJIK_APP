import '../../models/auth/auth_response.dart';
import '../../models/auth/login_request.dart';
import '../../models/auth/signup_request.dart';

abstract class AuthRemoteSource {
  /// 이메일 로그인 (3.3)
  Future<AuthResponse> emailLogin(LoginRequest request);

  /// 구글 로그인
  Future<AuthResponse> googleLogin(String googleToken);

  /// 회원가입 (3.2) - guestKey 선택 포함
  Future<AuthResponse> signup(SignupRequest request);

  /// 로그아웃 (3.5)
  Future<void> logout();

  /// 토큰 갱신 (3.4)
  Future<TokenRefreshResponse> refreshToken(String refreshToken);
}