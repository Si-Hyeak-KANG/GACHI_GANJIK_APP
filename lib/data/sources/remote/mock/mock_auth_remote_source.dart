import '../auth_remote_source.dart';
import '../../../models/auth/auth_response.dart';
import '../../../models/auth/login_request.dart';
import '../../../models/auth/signup_request.dart';
import '../../../models/auth/user_dto.dart';
import '../../../../../core/network/network_exception.dart';

class MockAuthRemoteSource implements AuthRemoteSource {

  // 테스트 계정 (이메일 로그인용)
  static const _testEmail = 'test@test.com';
  static const _testPassword = '1234';

  @override
  Future<AuthResponse> emailLogin(LoginRequest request) async {

    await Future.delayed(const Duration(seconds: 1));

    if (request.email == _testEmail && request.password == _testPassword) {
      return _mockAuthResponse(
        userId: 'testUserId1',
        email: request.email,
        nickname: '석스키',
      );
    }

    // 로그인 실패 시뮬레이션
    throw NetworkException(
      message: '이메일 또는 비밀번호가 올바르지 않습니다',
      type: NetworkExceptionType.badRequest,
      statusCode: 400,
    );
  }

  @override
  Future<AuthResponse> googleLogin(String googleToken) async {
    await Future.delayed(const Duration(seconds: 1));

    // Google 로그인은 항상 성공 (Mock)
    return _mockAuthResponse(
      userId: 'testUserIdGoogle',
      email: 'google@test.com',
      nickname: 'Google유저',
    );
  }

  @override
  Future<AuthResponse> signup(SignupRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    // 이미 존재하는 이메일 시뮬레이션
    if (request.email == _testEmail) {
      throw NetworkException(
        message: '이미 사용 중인 이메일입니다',
        type: NetworkExceptionType.badRequest,
        statusCode: 400,
      );
    }

    return _mockAuthResponse(
      userId: 'testUserId2',
      email: request.email,
      nickname: request.nickname,
    );
  }

  // Mock 응답 생성 헬퍼
  AuthResponse _mockAuthResponse({
    required String userId,
    required String email,
    required String nickname,
  }) {
    return AuthResponse(
      accessToken: 'mock_access_token_$userId',
      refreshToken: 'mock_refresh_token_$userId',
      user: UserDto(
        userId: userId,
        email: email,
        nickname: nickname,
        profileImageUrl: null,
        createdAt: '',
        userTag: '',
      ),
    );
  }
}