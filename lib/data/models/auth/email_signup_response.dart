import 'auth_response.dart';

/// 이메일 회원가입 응답
/// - 생성 완료: needsLink=false → [auth] 채워짐(로그인)
/// - 이메일 연동 필요: needsLink=true → 동일 이메일이 다른 로그인 수단으로 이미 가입됨
///   → [linkTicket]/[maskedEmail]로 연동 확인
class EmailSignupResponse {
  final bool needsLink;
  final AuthResponse? auth;
  final String? linkTicket;
  final String? maskedEmail;

  EmailSignupResponse({
    this.needsLink = false,
    this.auth,
    this.linkTicket,
    this.maskedEmail,
  });

  factory EmailSignupResponse.fromJson(Map<String, dynamic> data) {
    if (data['needsLink'] as bool? ?? false) {
      return EmailSignupResponse(
        needsLink: true,
        linkTicket: data['linkTicket'] as String?,
        maskedEmail: data['maskedEmail'] as String?,
      );
    }
    return EmailSignupResponse(
      auth: AuthResponse(
        userId: (data['userId'] as num).toString(),
        nickname: data['nickname'] as String,
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        linkedAlbumCount: data['linkedAlbumCount'] as int? ?? 0,
        linkedPhotoCount: data['linkedPhotoCount'] as int? ?? 0,
      ),
    );
  }
}