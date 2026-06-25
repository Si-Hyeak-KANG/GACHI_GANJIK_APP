import '../auth_remote_source.dart';
import '../../../models/auth/auth_response.dart';
import '../../../models/auth/login_request.dart';
import '../../../models/auth/signup_request.dart';
import '../../../../../core/network/network_exception.dart';

class MockAuthRemoteSource implements AuthRemoteSource {

  static const _testEmail = 'test@test.com';
  static const _testPassword = '1234';

  @override
  Future<AuthResponse> emailLogin(LoginRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.email == _testEmail && request.password == _testPassword) {
      return AuthResponse(
        userId: '1',
        nickname: '석스키',
        accessToken: 'mock_access_token_1',
        refreshToken: 'mock_refresh_token_1',
      );
    }

    throw NetworkException(
      message: '이메일 또는 비밀번호가 올바르지 않습니다.',
      type: NetworkExceptionType.badRequest,
      statusCode: 401,
    );
  }

  @override
  Future<AuthResponse> googleLogin(String idToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthResponse(
      userId: '2',
      nickname: 'Google유저',
      accessToken: 'mock_access_token_2',
      refreshToken: 'mock_refresh_token_2',
    );
  }

  @override
  Future<AuthResponse> signup(SignupRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.email == _testEmail) {
      throw NetworkException(
        message: '이미 사용 중인 이메일입니다.',
        type: NetworkExceptionType.badRequest,
        statusCode: 409,
      );
    }

    return AuthResponse(
      userId: '3',
      nickname: request.nickname,
      accessToken: 'mock_access_token_3',
      refreshToken: 'mock_refresh_token_3',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> sendVerificationCode(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: 항상 성공
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: 코드가 '123456'이면 성공, 그 외 실패
    if (code != '123456') {
      throw NetworkException(
        message: '인증 코드가 올바르지 않습니다.',
        type: NetworkExceptionType.badRequest,
        statusCode: 400,
        errorCode: 'EMAIL_VERIFICATION_INVALID',
      );
    }
  }
}