import '../auth_remote_source.dart';
import '../../../models/auth/auth_response.dart';
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
    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponse(
      userId: (data['userId'] as num).toString(),
      nickname: data['nickname'] as String,
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  @override
  Future<AuthResponse> googleLogin(String idToken) async {
    final response = await _dioClient.post(
      ApiConstants.googleLogin,
      data: {'idToken': idToken},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponse(
      userId: (data['userId'] as num).toString(),
      nickname: data['nickname'] as String,
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  @override
  Future<AuthResponse> signup(SignupRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.signup,
      data: request.toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponse(
      userId: (data['userId'] as num).toString(),
      nickname: data['nickname'] as String,
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      linkedAlbumCount: data['linkedAlbumCount'] as int? ?? 0,
      linkedPhotoCount: data['linkedPhotoCount'] as int? ?? 0,
    );
  }

  @override
  Future<void> logout() async {
    await _dioClient.post(ApiConstants.logout);
  }

  @override
  Future<void> sendVerificationCode(String email) async {
    await _dioClient.post(
      '/auth/email/send',
      data: {'email': email},
    );
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    await _dioClient.post(
      '/auth/email/verify',
      data: {'email': email, 'code': code},
    );
  }

}