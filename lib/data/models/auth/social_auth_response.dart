import 'auth_response.dart';

/// 소셜 로그인 응답 (3-state)
/// - 기존 사용자: isNewUser=false, needsLink=false → [auth] 채워짐 → 바로 로그인
/// - 이메일 연동 필요: needsLink=true → [linkTicket]/[maskedEmail] (동일 이메일 기존 계정 존재)
/// - 신규 사용자: isNewUser=true → [signupTicket] + provider 프로필 → 닉네임 온보딩
class SocialAuthResponse {
  final bool isNewUser;
  final bool needsLink;

  // 기존 사용자(로그인)
  final AuthResponse? auth;

  // 신규 사용자(온보딩)
  final String? signupTicket;
  final String? profileNickname;
  final String? profileEmail;
  final String? profileImageUrl;

  // 이메일 연동 필요
  final String? linkTicket;
  final String? maskedEmail;

  SocialAuthResponse({
    this.isNewUser = false,
    this.needsLink = false,
    this.auth,
    this.signupTicket,
    this.profileNickname,
    this.profileEmail,
    this.profileImageUrl,
    this.linkTicket,
    this.maskedEmail,
  });

  /// data = response.data['data']
  factory SocialAuthResponse.fromJson(Map<String, dynamic> data) {
    // 1) 이메일 연동 필요
    if (data['needsLink'] as bool? ?? false) {
      return SocialAuthResponse(
        needsLink: true,
        linkTicket: data['linkTicket'] as String?,
        maskedEmail: data['maskedEmail'] as String?,
      );
    }

    // 2) 신규 사용자
    if (data['isNewUser'] as bool? ?? false) {
      final profile = (data['profile'] as Map<String, dynamic>?) ?? const {};
      return SocialAuthResponse(
        isNewUser: true,
        signupTicket: data['signupTicket'] as String?,
        profileNickname: profile['nickname'] as String?,
        profileEmail: profile['email'] as String?,
        profileImageUrl: profile['profileImageUrl'] as String?,
      );
    }

    // 3) 기존 사용자
    return SocialAuthResponse(
      auth: AuthResponse(
        userId: (data['userId'] as num).toString(),
        nickname: data['nickname'] as String,
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      ),
    );
  }
}