import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/local_storage.dart';
import '../models/auth/login_request.dart';
import '../models/auth/signup_request.dart';
import '../sources/remote/auth_remote_source.dart';

// → DataSource(API 통신)와 Domain(비즈니스 로직)을 연결
// → 토큰 저장, DTO→Entity 변환 등 처리
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _remoteSource;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;

  AuthRepositoryImpl({
    required AuthRemoteSource remoteSource,
    required SecureStorage secureStorage,
    required LocalStorage localStorage,
  })  : _remoteSource = remoteSource,
        _secureStorage = secureStorage,
        _localStorage = localStorage;

  @override
  Future<User> emailLogin(String email, String password) async {
    final response = await _remoteSource.emailLogin(
      LoginRequest(email: email, password: password),
    );

    // 토큰 저장
    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.user.id,
    );

    return response.user.toEntity();
  }

  @override
  Future<User> googleLogin() async {

    final response = await _remoteSource.googleLogin('mock_google_token');

    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.user.id,
    );

    return response.user.toEntity();
  }

  @override
  Future<User> signup(String email, String password, String nickname) async {
    final response = await _remoteSource.signup(
      SignupRequest(email: email, password: password, nickname: nickname),
    );

    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.user.id,
    );

    return response.user.toEntity();
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearTokens();
    await _localStorage.clearAll();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // 토큰 및 유저 ID 저장 헬퍼
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
    await _localStorage.saveUserId(userId);
  }
}