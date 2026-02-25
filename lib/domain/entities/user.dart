class User {
  final String userId;              // UUID
  final String email;
  final String nickname;
  final String userTag;             // #AB1C23 형식
  final String? profileImageUrl;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.userTag,
    this.profileImageUrl,
    required this.createdAt,
  });

  // 프로필 이미지 첫 글자
  String get initial => nickname.isNotEmpty ? nickname[0] : '?';

  // 하위 호환: id getter (Deprecated)
  @Deprecated('Use userId instead')
  String get id => userId;

  // 하위 호환: profileImage getter (Deprecated)
  @Deprecated('Use profileImageUrl instead')
  String? get profileImage => profileImageUrl;
}