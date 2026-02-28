import '../../../../../core/network/dio_client.dart';
import '../../../models/auth/auth_response.dart';
import '../../../models/auth/login_request.dart';
import '../../../models/auth/signup_request.dart';
import '../auth_remote_source.dart';

class RealAuthRemoteSource implements AuthRemoteSource {
  final DioClient _dioClient;

  RealAuthRemoteSource({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<AuthResponse> emailLogin(LoginRequest request) async {
    final response = await _dioClient.post(
      '/auth/login',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> googleLogin(String googleToken) async {
    final response = await _dioClient.post(
      '/auth/google',
      data: {'googleToken': googleToken},
    );
    return AuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> signup(SignupRequest request) async {
    final response = await _dioClient.post(
      '/auth/signup',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _dioClient.post('/auth/logout');
  }

  @override
  Future<TokenRefreshResponse> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      '/auth/token/refresh',
      data: {'refreshToken': refreshToken},
    );
    return TokenRefreshResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}