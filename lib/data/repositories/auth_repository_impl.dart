import 'package:google_sign_in/google_sign_in.dart';
// 앱의 User 엔티티와 이름 충돌하는 Kakao User 클래스는 숨김
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' hide User;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/local_storage.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/social_auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/signup_request.dart';
import '../sources/remote/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _remoteSource;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;

  // Google 웹 클라이언트 ID (env.json 주입)
  static const String _googleServerClientId =
  String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  final _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    serverClientId: _googleServerClientId,
  );

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
  Future<SocialLoginOutcome> googleLogin() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const SocialLoginCancelledException();
    }
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
    }
    final res = await _remoteSource.googleLogin(idToken);
    return _toOutcome(res, email: googleUser.email);
  }

  @override
  Future<SocialLoginOutcome> kakaoLogin() async {
    final OAuthToken token;
    try {
      token = await _kakaoAuthenticate();
    } catch (e) {
      if (_isKakaoCancel(e)) throw const SocialLoginCancelledException();
      rethrow;
    }
    final res = await _remoteSource.kakaoLogin(token.accessToken);
    return _toOutcome(res, email: '');
  }

  @override
  Future<SocialLoginOutcome> naverLogin() async {
    // 네이버 SDK가 이전 세션 토큰을 캐시해 로그인 창 없이 통과하는 것을 방지.
    // 로그인 직전 세션을 비워 매번 로그인/동의 창이 뜨도록 함.
    try {
      await FlutterNaverLogin.logOut();
    } catch (_) {}

    final result = await FlutterNaverLogin.logIn();
    if (result.status != NaverLoginStatus.loggedIn) {
      // 취소면 조용히 무시, 그 외(오류)는 로그 대상 예외로 구분
      if (result.status.name.toLowerCase().contains('cancel')) {
        throw const SocialLoginCancelledException();
      }
      throw Exception('Naver 로그인에 실패했습니다.');
    }
    final naverToken = await FlutterNaverLogin.getCurrentAccessToken();
    final accessToken = naverToken.accessToken;
    if (accessToken.isEmpty) {
      throw Exception('Naver 인증 토큰을 가져올 수 없습니다.');
    }
    final res = await _remoteSource.naverLogin(accessToken);
    return _toOutcome(res, email: result.account?.email ?? '');
  }

  @override
  Future<User> completeSocialSignup({
    required String signupTicket,
    required String nickname,
  }) async {
    final auth = await _remoteSource.socialSignupComplete(
      signupTicket: signupTicket,
      nickname: nickname,
    );
    await _saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );
    return _responseToUser(auth, email: '');
  }

  @override
  Future<User> linkSocialAccount({required String linkTicket}) async {
    final auth = await _remoteSource.socialLink(linkTicket: linkTicket);
    await _saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );
    return _responseToUser(auth, email: '');
  }

  @override
  Future<User> linkEmailAccount({
    required String linkTicket,
    required String password,
  }) async {
    final auth = await _remoteSource.emailLink(
      linkTicket: linkTicket,
      password: password,
    );
    await _saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );
    return _responseToUser(auth, email: '');
  }

  @override
  Future<EmailSignupOutcome> signup(String email, String password, String nickname,
      {String? guestKey}) async {
    final res = await _remoteSource.signup(
      SignupRequest(email: email, password: password, nickname: nickname, guestKey: guestKey),
    );

    if (res.needsLink) {
      return EmailSignupOutcome.linkRequired(
        linkTicket: res.linkTicket ?? '',
        maskedEmail: res.maskedEmail,
      );
    }

    final auth = res.auth!;
    await _saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );
    return EmailSignupOutcome.created(_responseToUser(auth, email: email));
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteSource.logout();
    } catch (_) {}

    await _secureStorage.clearTokens();
    await _localStorage.clearAll();

    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    try {
      await UserApi.instance.logout();
    } catch (_) {}
    try {
      await FlutterNaverLogin.logOut();
    } catch (_) {}
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

  // ── 내부 ──────────────────────────────────

  // 소셜 응답 → 로그인 완료 / 이메일 연동 필요 / 온보딩 필요
  Future<SocialLoginOutcome> _toOutcome(SocialAuthResponse res,
      {required String email}) async {
    if (res.needsLink) {
      return SocialLoginOutcome.linkRequired(
        linkTicket: res.linkTicket ?? '',
        maskedEmail: res.maskedEmail,
      );
    }
    if (res.isNewUser) {
      return SocialLoginOutcome.onboarding(
        signupTicket: res.signupTicket ?? '',
        suggestedNickname: res.profileNickname,
      );
    }
    final auth = res.auth!;
    await _saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );
    return SocialLoginOutcome.loggedIn(_responseToUser(auth, email: email));
  }

  // 카카오톡 앱이 있으면 앱으로, 없으면 카카오계정으로 로그인
  Future<OAuthToken> _kakaoAuthenticate() async {
    if (await isKakaoTalkInstalled()) {
      try {
        return await UserApi.instance.loginWithKakaoTalk();
      } catch (e) {
        // 사용자가 취소한 경우엔 계정 로그인으로 넘기지 않고 그대로 전달
        if (_isKakaoCancel(e)) rethrow;
        return await UserApi.instance.loginWithKakaoAccount();
      }
    }
    return await UserApi.instance.loginWithKakaoAccount();
  }

  // 카카오 SDK의 취소 예외 판별 (버전별 예외 타입 차이를 문자열로 흡수)
  bool _isKakaoCancel(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('cancel') || s.contains('access_denied');
  }

  // AuthResponse → User (userTag/createdAt은 GET /users/me 연동 시 실제 값으로 교체)
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