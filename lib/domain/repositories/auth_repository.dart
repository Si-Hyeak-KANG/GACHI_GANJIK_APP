import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> emailLogin(String email, String password);
  Future<User> googleLogin();
  Future<User> signup(String email, String password, String nickname);
  Future<void> logout();
  Future<bool> isLoggedIn();
}