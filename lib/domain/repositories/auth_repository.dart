import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> emailLogin(String email, String password);
  Future<User> googleLogin();
  Future<User> signup(String email, String password, String nickname, {String? guestKey});
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<void> sendVerificationCode(String email);
  Future<void> verifyEmailCode(String email, String code);
}