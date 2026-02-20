class UpdateProfileRequest {
  final String? nickname;
  final String? profileImageUrl;

  UpdateProfileRequest({
    this.nickname,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
    if (nickname != null) 'nickname': nickname,
    if (profileImageUrl != null) 'profileImage': profileImageUrl,
  };
}