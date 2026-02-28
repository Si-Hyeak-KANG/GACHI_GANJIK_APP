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
      return _buildResponse(
        userId: 'testUserId1',
        email: request.email,
        nickname: '석스키',
      );
    }

    throw NetworkException(
      message: '이메일 또는 비밀번호가 올바르지 않습니다',
      type: NetworkExceptionType.badRequest,
      statusCode: 400,
      errorCode: 'INVALID_CREDENTIALS',
    );
  }

  @override
  Future<AuthResponse> googleLogin(String googleToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return _buildResponse(
      userId: 'testUserIdGoogle',
      email: 'google@test.com',
      nickname: 'Google유저',
    );
  }

  @override
  Future<AuthResponse> signup(SignupRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.email == _testEmail) {
      throw NetworkException(
        message: '이미 사용 중인 이메일입니다',
        type: NetworkExceptionType.conflict,
        statusCode: 409,
        errorCode: 'EMAIL_ALREADY_EXISTS',
      );
    }

    return _buildResponse(
      userId: 'testUserId2',
      email: request.email,
      nickname: request.nickname,
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<TokenRefreshResponse> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TokenRefreshResponse(
      accessToken: 'mock_new_access_token',
      refreshToken: 'mock_new_refresh_token',
    );
  }

  AuthResponse _buildResponse({
    required String userId,
    required String email,
    required String nickname,
  }) {
    return AuthResponse(
      userId: userId,
      nickname: nickname,
      accessToken: 'mock_access_token_$userId',
      refreshToken: 'mock_refresh_token_$userId',
    );
  }
}