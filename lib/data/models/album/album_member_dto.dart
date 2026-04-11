class AlbumMemberDto {
  final String userId;
  final String nickname;
  final String userTag;
  final String? profileImageUrl;
  final String role;
  final String joinedAt;

  AlbumMemberDto({
    required this.userId,
    required this.nickname,
    required this.userTag,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
  });

  factory AlbumMemberDto.fromJson(Map<String, dynamic> json) {
    return AlbumMemberDto(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      userTag: json['userTag'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      role: json['role'] as String,
      joinedAt: json['joinedAt'] as String,
    );
  }
}