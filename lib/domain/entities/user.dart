class User {
  final int id;
  final String email;
  final String nickname;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImage,
  });
}
