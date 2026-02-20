import 'dart:io';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user/update_profile_request.dart';
import '../sources/firebase/firebase_storage_source.dart';
import '../sources/remote/user_remote_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteSource _remoteSource;
  final FirebaseStorageSource _storageSource;

  UserRepositoryImpl({
    required UserRemoteSource remoteSource,
    required FirebaseStorageSource storageSource,
  })  : _remoteSource = remoteSource,
        _storageSource = storageSource;

  @override
  Future<User> getCurrentUser() async {
    final dto = await _remoteSource.getCurrentUser();
    return dto.toEntity();
  }

  @override
  Future<User> updateProfile({String? nickname, File? profileImage}) async {
    String? imageUrl;

    // 프로필 이미지가 있으면 Firebase Storage에 업로드
    if (profileImage != null) {
      imageUrl = await _storageSource.uploadProfileImage(profileImage);
    }

    final dto = await _remoteSource.updateProfile(
      UpdateProfileRequest(
        nickname: nickname,
        profileImageUrl: imageUrl,
      ),
    );

    return dto.toEntity();
  }

  @override
  Future<void> deleteAccount() async {
    await _remoteSource.deleteAccount();
  }
}