import '../../../domain/entities/user.dart';

class UserDto {
  final String userId;
  final String email;
  final String nickname;
  final String userTag;
  final String? profileImageUrl;
  final String createdAt;

  UserDto({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.userTag,
    this.profileImageUrl,
    required this.createdAt,
  });

  // ✅ API 응답 파싱
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['userId'] as String,           // ✅ API 필드명
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      userTag: json['userTag'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  // ✅ API 요청용 (회원가입 시)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
    };
  }

  // ✅ 엔티티 변환
  User toEntity() {
    return User(
      userId: userId,
      email: email,
      nickname: nickname,
      userTag: userTag,
      profileImageUrl: profileImageUrl,
      createdAt: DateTime.parse(createdAt),
    );
  }

  // ✅ 하위 호환: id getter
  @Deprecated('Use userId instead')
  String get id => userId;

  // ✅ 하위 호환: profileImage getter
  @Deprecated('Use profileImageUrl instead')
  String? get profileImage => profileImageUrl;
}