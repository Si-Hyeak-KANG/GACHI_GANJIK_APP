import '../../../models/auth/email_signup_response.dart';
import '../auth_remote_source.dart';
import '../../../models/auth/auth_response.dart';
import '../../../models/auth/social_auth_response.dart';
import '../../../models/auth/login_request.dart';
import '../../../models/auth/signup_request.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/constants/api_constants.dart';

class RealAuthRemoteSource implements AuthRemoteSource {
  final DioClient _dioClient;

  RealAuthRemoteSource({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<AuthResponse> emailLogin(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return _parseAuth(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SocialAuthResponse> googleLogin(String idToken) async {
    final response = await _dioClient.post(
      ApiConstants.googleLogin,
      data: {'idToken': idToken},
    );
    return SocialAuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SocialAuthResponse> kakaoLogin(String accessToken) async {
    final response = await _dioClient.post(
      ApiConstants.kakaoLogin,
      data: {'accessToken': accessToken},
    );
    return SocialAuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SocialAuthResponse> naverLogin(String accessToken) async {
    final response = await _dioClient.post(
      ApiConstants.naverLogin,
      data: {'accessToken': accessToken},
    );
    return SocialAuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> socialSignupComplete({
    required String signupTicket,
    required String nickname,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.socialComplete,
      data: {
        'signupTicket': signupTicket,
        'nickname': nickname,
      },
    );
    return _parseAuth(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> socialLink({required String linkTicket}) async {
    final response = await _dioClient.post(
      ApiConstants.socialLink,
      data: {'linkTicket': linkTicket},
    );
    return _parseAuth(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> emailLink({
    required String linkTicket,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.emailLink,
      data: {'linkTicket': linkTicket, 'password': password},
    );
    return _parseAuth(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<EmailSignupResponse> signup(SignupRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.signup,
      data: request.toJson(),
    );
    return EmailSignupResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _dioClient.post(ApiConstants.logout);
  }

  @override
  Future<void> sendVerificationCode(String email) async {
    await _dioClient.post('/auth/email/send', data: {'email': email});
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    await _dioClient.post('/auth/email/verify', data: {'email': email, 'code': code});
  }

  AuthResponse _parseAuth(Map<String, dynamic> data) {
    return AuthResponse(
      userId: (data['userId'] as num).toString(),
      nickname: data['nickname'] as String,
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}