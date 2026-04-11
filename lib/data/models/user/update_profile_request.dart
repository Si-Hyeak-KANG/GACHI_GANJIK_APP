class UpdateProfileRequest {
  final String? nickname;
  final String? profileImageUrl;
  final String? currentPassword;
  final String? newPassword;
  final String? passwordConfirm;

  UpdateProfileRequest({
    this.nickname,
    this.profileImageUrl,
    this.currentPassword,
    this.newPassword,
    this.passwordConfirm,
  });

  Map<String, dynamic> toJson() => {
    if (nickname != null) 'nickname': nickname,
    if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    if (currentPassword != null) 'currentPassword': currentPassword,
    if (newPassword != null) 'newPassword': newPassword,
    if (passwordConfirm != null) 'passwordConfirm': passwordConfirm,
  };
}