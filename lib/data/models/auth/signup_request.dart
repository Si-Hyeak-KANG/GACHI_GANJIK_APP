// API 명세서 3.2 회원가입 요청 기준
class SignupRequest {
  final String email;
  final String password;
  final String nickname;
  // GUEST → 회원 전환 시 기존 활동 연동 (선택)
  final String? guestKey;

  SignupRequest({
    required this.email,
    required this.password,
    required this.nickname,
    this.guestKey,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'email': email,
      'password': password,
      'nickname': nickname,
    };
    if (guestKey != null) {
      json['guestKey'] = guestKey;
    }
    return json;
  }
}