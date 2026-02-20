import 'dart:io';
import '../entities/user.dart';

abstract class UserRepository {
  Future<User> getCurrentUser();
  Future<User> updateProfile({String? nickname, File? profileImage});
  Future<void> deleteAccount();
}