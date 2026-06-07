class GuestRegisterResponse {
  final String guestId;
  final String guestKey;
  final String nickname;
  final String albumId;

  GuestRegisterResponse({
    required this.guestId,
    required this.guestKey,
    required this.nickname,
    required this.albumId,
  });

  factory GuestRegisterResponse.fromJson(Map<String, dynamic> json) {
    return GuestRegisterResponse(
      guestId: json['guestId']?.toString() ?? '',
      guestKey: json['guestKey'] as String,
      nickname: json['nickname'] as String,
      albumId: json['albumId']?.toString() ?? '',
    );
  }
}

class GuestRestoreResponse {
  final String guestId;
  final String guestKey;
  final String nickname;

  GuestRestoreResponse({
    required this.guestId,
    required this.guestKey,
    required this.nickname,
  });

  factory GuestRestoreResponse.fromJson(Map<String, dynamic> json) {
    return GuestRestoreResponse(
      guestId: json['guestId']?.toString() ?? '',
      guestKey: json['guestKey'] as String,
      nickname: json['nickname'] as String,
    );
  }
}