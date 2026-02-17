import '../../../domain/entities/user.dart';

class UserDto {
  final int id;
  final String email;
  final String nickname;
  final String? profileImage;

  UserDto({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImage,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String?,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      nickname: nickname,
      profileImage: profileImage,
    );
  }
}
