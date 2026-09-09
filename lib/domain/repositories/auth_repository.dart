import '../entities/user.dart';

/// 사용자가 소셜 로그인 창을 취소했을 때 던지는 예외.
/// 컨트롤러는 이를 에러 알럿 없이 조용히 무시한다.
class SocialLoginCancelledException implements Exception {
  const SocialLoginCancelledException();
}

/// 소셜 로그인 결과 (3-state)
/// - 기존 사용자: [user] 채워짐 → 바로 로그인
/// - 신규: needsOnboarding=true → [signupTicket]/[suggestedNickname] → 닉네임 온보딩
/// - 이메일 연동 필요: needsLink=true → [linkTicket]/[maskedEmail] → 연동 확인
class SocialLoginOutcome {
  final User? user;
  final bool needsOnboarding;
  final bool needsLink;
  final String? signupTicket;
  final String? suggestedNickname;
  final String? linkTicket;
  final String? maskedEmail;

  const SocialLoginOutcome.loggedIn(User this.user)
      : needsOnboarding = false,
        needsLink = false,
        signupTicket = null,
        suggestedNickname = null,
        linkTicket = null,
        maskedEmail = null;

  const SocialLoginOutcome.onboarding({
    required String this.signupTicket,
    this.suggestedNickname,
  })  : user = null,
        needsOnboarding = true,
        needsLink = false,
        linkTicket = null,
        maskedEmail = null;

  const SocialLoginOutcome.linkRequired({
    required String this.linkTicket,
    this.maskedEmail,
  })  : user = null,
        needsOnboarding = false,
        needsLink = true,
        signupTicket = null,
        suggestedNickname = null;
}

/// 이메일 회원가입 결과
/// - 생성 완료: [user] 채워짐(로그인)
/// - 이메일 연동 필요: needsLink=true → [linkTicket]/[maskedEmail]
class EmailSignupOutcome {
  final User? user;
  final bool needsLink;
  final String? linkTicket;
  final String? maskedEmail;

  const EmailSignupOutcome.created(User this.user)
      : needsLink = false,
        linkTicket = null,
        maskedEmail = null;

  const EmailSignupOutcome.linkRequired({
    required String this.linkTicket,
    this.maskedEmail,
  })  : user = null,
        needsLink = true;
}

abstract class AuthRepository {
  Future<User> emailLogin(String email, String password);

  Future<SocialLoginOutcome> googleLogin();
  Future<SocialLoginOutcome> kakaoLogin();
  Future<SocialLoginOutcome> naverLogin();

  /// 신규 소셜 사용자 온보딩 완료 (닉네임만) → 계정 생성 후 로그인
  Future<User> completeSocialSignup({
    required String signupTicket,
    required String nickname,
  });

  /// 기존 계정에 소셜 로그인 수단 연결
  Future<User> linkSocialAccount({required String linkTicket});

  /// 기존 계정에 이메일/비밀번호 로그인 수단 연결
  Future<User> linkEmailAccount({
    required String linkTicket,
    required String password,
  });

  /// 이메일 회원가입 → 생성(로그인) 또는 이메일 연동 필요
  Future<EmailSignupOutcome> signup(String email, String password, String nickname,
      {String? guestKey});

  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<void> sendVerificationCode(String email);
  Future<void> verifyEmailCode(String email, String code);
}