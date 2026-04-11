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
  Future<User> updateProfile({
    String? nickname,
    File? profileImage,
    String? currentPassword,
    String? newPassword,
    String? passwordConfirm,
  }) async {
    // 프로필 이미지: Firebase 업로드 후 URL만 서버에 저장
    if (profileImage != null) {
      final imageUrl = await _storageSource.uploadProfileImage(profileImage);
      await _remoteSource.updateProfileImage(imageUrl);
    }

    // 닉네임 또는 비밀번호 변경이 있는 경우에만 PATCH 호출
    final hasProfileUpdate = nickname != null || newPassword != null;
    if (hasProfileUpdate) {
      final dto = await _remoteSource.updateProfile(
        UpdateProfileRequest(
          nickname: nickname,
          currentPassword: currentPassword,
          newPassword: newPassword,
          passwordConfirm: passwordConfirm,
        ),
      );
      return dto.toEntity();
    }

    // 이미지만 변경한 경우 최신 프로필 재조회
    return await getCurrentUser();
  }

  @override
  Future<void> deleteAccount() async {
    await _remoteSource.deleteAccount();
  }
}