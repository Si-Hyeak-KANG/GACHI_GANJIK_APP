// API 명세서 3.2 (회원가입), 3.3 (로그인) 응답 기준
// 응답 필드: userId, nickname, accessToken, refreshToken
// 회원가입 추가 필드: linkedAlbumCount, linkedPhotoCount
class AuthResponse {
  final String userId;
  final String nickname;
  final String accessToken;
  final String refreshToken;
  // 회원가입 시 guestKey 연동 결과 (없으면 0)
  final int linkedAlbumCount;
  final int linkedPhotoCount;

  AuthResponse({
    required this.userId,
    required this.nickname,
    required this.accessToken,
    required this.refreshToken,
    this.linkedAlbumCount = 0,
    this.linkedPhotoCount = 0,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      linkedAlbumCount: json['linkedAlbumCount'] as int? ?? 0,
      linkedPhotoCount: json['linkedPhotoCount'] as int? ?? 0,
    );
  }
}

// 토큰 갱신 응답 (3.4)
class TokenRefreshResponse {
  final String accessToken;
  final String refreshToken;

  TokenRefreshResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}