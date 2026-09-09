import '../../../models/auth/email_signup_response.dart';
import '../auth_remote_source.dart';
import '../../../models/auth/auth_response.dart';
import '../../../models/auth/social_auth_response.dart';
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

  // Mock: Google = 기존 사용자(바로 로그인)
  @override
  Future<SocialAuthResponse> googleLogin(String idToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return SocialAuthResponse(
      auth: AuthResponse(
        userId: '2',
        nickname: 'Google유저',
        accessToken: 'mock_access_token_2',
        refreshToken: 'mock_refresh_token_2',
      ),
    );
  }

  // Mock: Kakao = 신규 사용자(닉네임 온보딩)
  @override
  Future<SocialAuthResponse> kakaoLogin(String accessToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return SocialAuthResponse(
      isNewUser: true,
      signupTicket: 'mock_ticket_kakao',
      profileNickname: '카카오사용자',
    );
  }

  // Mock: Naver = 동일 이메일 기존 계정 존재(연동 다이얼로그 테스트용)
  @override
  Future<SocialAuthResponse> naverLogin(String accessToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return SocialAuthResponse(
      needsLink: true,
      linkTicket: 'mock_link_ticket_naver',
      maskedEmail: 'zl****@naver.com',
    );
  }

  // Mock: 온보딩 완료 → 신규 계정 생성(로그인)
  @override
  Future<AuthResponse> socialSignupComplete({
    required String signupTicket,
    required String nickname,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthResponse(
      userId: '10',
      nickname: nickname,
      accessToken: 'mock_access_token_new',
      refreshToken: 'mock_refresh_token_new',
    );
  }

  // Mock: 소셜 연동 → 기존 계정 반환
  @override
  Future<AuthResponse> socialLink({required String linkTicket}) async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthResponse(
      userId: '1',
      nickname: '석스키',
      accessToken: 'mock_access_token_linked',
      refreshToken: 'mock_refresh_token_linked',
    );
  }

  // Mock: 이메일 연동 → 기존 계정 반환
  @override
  Future<AuthResponse> emailLink({
    required String linkTicket,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthResponse(
      userId: '1',
      nickname: '석스키',
      accessToken: 'mock_access_token_email_linked',
      refreshToken: 'mock_refresh_token_email_linked',
    );
  }

  // Mock: signup — 'link@test.com' = 이메일 연동 필요, test@test.com = 이미 가입(409), 그 외 생성
  @override
  Future<EmailSignupResponse> signup(SignupRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    if (request.email == _testEmail) {
      throw NetworkException(
        message: '이미 가입된 이메일입니다. 로그인해주세요.',
        type: NetworkExceptionType.badRequest,
        statusCode: 409,
        errorCode: 'EMAIL_ALREADY_EXISTS',
      );
    }
    if (request.email == 'link@test.com') {
      return EmailSignupResponse(
        needsLink: true,
        linkTicket: 'mock_link_ticket_email',
        maskedEmail: 'li****@test.com',
      );
    }
    return EmailSignupResponse(
      auth: AuthResponse(
        userId: '3',
        nickname: request.nickname,
        accessToken: 'mock_access_token_3',
        refreshToken: 'mock_refresh_token_3',
      ),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> sendVerificationCode(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
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