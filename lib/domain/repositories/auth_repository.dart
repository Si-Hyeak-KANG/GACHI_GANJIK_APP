import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> emailLogin(String email, String password);
  Future<User> googleLogin();
  // guestKey: GUEST → 회원 전환 시 기존 활동 연동 (선택)
  Future<User> signup(String email, String password, String nickname, {String? guestKey});
  Future<void> logout();
  Future<bool> isLoggedIn();
}