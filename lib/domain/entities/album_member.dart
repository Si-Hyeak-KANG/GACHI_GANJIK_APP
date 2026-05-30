class AlbumMember {
  final String memberId;
  final String userId;
  final String nickname;
  final String userTag;
  final String? profileImageUrl;
  final String role;
  final String joinedAt;

  AlbumMember({
    required this.memberId,
    required this.userId,
    required this.nickname,
    required this.userTag,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
  });

  bool get isOwner => role == 'OWNER';
  bool get isAdmin => role == 'ADMIN';
  bool get isMember => role == 'MEMBER';

  String get roleDisplay {
    switch (role) {
      case 'OWNER':
        return 'OWNER';
      case 'ADMIN':
        return 'ADMIN';
      default:
        return 'MEMBER';
    }
  }
}