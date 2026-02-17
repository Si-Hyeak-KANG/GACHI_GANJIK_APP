import 'user_dto.dart';

// 로그인/회원가입 공통 응답 구조
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}