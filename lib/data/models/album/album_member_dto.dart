class AlbumMemberDto {
  final String memberId;
  final String userId;
  final String nickname;
  final String userTag;
  final String? profileImageUrl;
  final String role;
  final String joinedAt;

  AlbumMemberDto({
    required this.memberId,
    required this.userId,
    required this.nickname,
    required this.userTag,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
  });

  factory AlbumMemberDto.fromJson(Map<String, dynamic> json) {
    return AlbumMemberDto(
      memberId: json['memberId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      nickname: json['nickname'] as String? ?? '',
      userTag: json['userTag'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      role: json['role'] as String? ?? 'MEMBER',
      joinedAt: json['joinedAt'] as String? ?? '',
    );
  }
}