// API 명세서 2. GUEST(비회원) 관련 DTO 및 인터페이스

class GuestEnterRequest {
  final String albumInviteCode;
  final String nickname;

  GuestEnterRequest({
    required this.albumInviteCode,
    required this.nickname,
  });

  Map<String, dynamic> toJson() => {
    'albumInviteCode': albumInviteCode,
    'nickname': nickname,
  };
}

class GuestResponse {
  final String guestId;
  final String guestKey;
  final String nickname;
  final String albumId;

  GuestResponse({
    required this.guestId,
    required this.guestKey,
    required this.nickname,
    required this.albumId,
  });

  factory GuestResponse.fromJson(Map<String, dynamic> json) {
    return GuestResponse(
      guestId: json['guestId'] as String,
      guestKey: json['guestKey'] as String,
      nickname: json['nickname'] as String,
      albumId: json['albumId'] as String,
    );
  }
}

abstract class GuestRemoteSource {
  /// 비회원 앨범 입장 (2.1)
  Future<GuestResponse> enterAsGuest(GuestEnterRequest request);
}