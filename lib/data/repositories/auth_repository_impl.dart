import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/local_storage.dart';
import '../models/auth/login_request.dart';
import '../models/auth/signup_request.dart';
import '../sources/remote/auth_remote_source.dart';

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
    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _localStorage.saveUserId(response.userId);

    return User(
      userId: response.userId,
      nickname: response.nickname,
      email: email,
      userTag: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<User> googleLogin() async {
    final response = await _remoteSource.googleLogin('google_token_placeholder');
    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _localStorage.saveUserId(response.userId);

    return User(
      userId: response.userId,
      nickname: response.nickname,
      email: '',
      userTag: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<User> signup(
      String email,
      String password,
      String nickname, {
        String? guestKey,
      }) async {
    final response = await _remoteSource.signup(
      SignupRequest(
        email: email,
        password: password,
        nickname: nickname,
        guestKey: guestKey,
      ),
    );
    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _localStorage.saveUserId(response.userId);

    if (guestKey != null) {
      await _secureStorage.clearGuestKey();
    }

    return User(
      userId: response.userId,
      nickname: response.nickname,
      email: email,
      userTag: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteSource.logout();
    } catch (_) {
      // 서버 로그아웃 실패해도 로컬은 정리
    } finally {
      await _secureStorage.clearAll();
      await _localStorage.clearAll();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}