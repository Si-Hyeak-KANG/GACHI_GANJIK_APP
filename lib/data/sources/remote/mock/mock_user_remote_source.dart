import '../user_remote_source.dart';
import '../../../models/auth/user_dto.dart';
import '../../../models/user/update_profile_request.dart';

class MockUserRemoteSource implements UserRemoteSource {
  // Mock 사용자 데이터
  UserDto _currentUser = UserDto(
    id: 1,
    email: 'test@test.com',
    nickname: '석스키',
    profileImage: null,
  );

  @override
  Future<UserDto> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<UserDto> updateProfile(UpdateProfileRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    // 업데이트
    _currentUser = UserDto(
      id: _currentUser.id,
      email: _currentUser.email,
      nickname: request.nickname ?? _currentUser.nickname,
      profileImage: request.profileImageUrl ?? _currentUser.profileImage,
    );

    return _currentUser;
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock이므로 실제 삭제는 안 함
  }
}