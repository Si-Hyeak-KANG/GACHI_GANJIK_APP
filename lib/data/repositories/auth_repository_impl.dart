import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/local_storage.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/signup_request.dart';
import '../sources/remote/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _remoteSource;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;

  final _googleSignIn = GoogleSignIn(scopes: ['email']);

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
    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.userId,
    );
    return _responseToUser(response, email: email);
  }

  @override
  Future<User> googleLogin() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google 로그인이 취소되었습니다.');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
    }

    final response = await _remoteSource.googleLogin(idToken);
    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.userId,
    );
    return _responseToUser(response, email: googleUser.email);
  }

  @override
  Future<User> signup(String email, String password, String nickname, {String? guestKey}) async {
    final response = await _remoteSource.signup(
      SignupRequest(email: email, password: password, nickname: nickname, guestKey: guestKey),
    );
    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.userId,
    );
    return _responseToUser(response, email: email);
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteSource.logout();
    } catch (_) {}

    await _secureStorage.clearTokens();
    await _localStorage.clearAll();

    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> sendVerificationCode(String email) async {
    await _remoteSource.sendVerificationCode(email);
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    await _remoteSource.verifyEmailCode(email, code);
  }

  // AuthResponse → User 엔티티 변환
  // userTag, createdAt은 인증 응답에 없으므로 빈 값 처리
  // → Users API (GET /users/me) 연동 시 실제 값으로 교체
  User _responseToUser(AuthResponse response, {required String email}) {
    return User(
      userId: response.userId,
      email: email,
      nickname: response.nickname,
      userTag: '',
      profileImageUrl: null,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
    await _localStorage.saveUserId(userId);
  }
}