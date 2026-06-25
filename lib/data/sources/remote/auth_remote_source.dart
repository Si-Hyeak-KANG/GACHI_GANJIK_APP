import '../../models/auth/auth_response.dart';
import '../../models/auth/login_request.dart';
import '../../models/auth/signup_request.dart';

abstract class AuthRemoteSource {
  Future<AuthResponse> emailLogin(LoginRequest request);
  Future<AuthResponse> googleLogin(String idToken);
  Future<AuthResponse> signup(SignupRequest request);
  Future<void> logout();
  Future<void> sendVerificationCode(String email);
  Future<void> verifyEmailCode(String email, String code);
}