import '../user_remote_source.dart';
import '../../../models/auth/user_dto.dart';
import '../../../models/user/update_profile_request.dart';

class MockUserRemoteSource implements UserRemoteSource {
  UserDto _currentUser = UserDto(
    userId: 'user-uuid-1',
    email: 'test@test.com',
    nickname: '석스키',
    profileImageUrl: null,
    userTag: '#AB1C23',
    createdAt: '2025-01-01T00:00:00Z',
  );

  @override
  Future<UserDto> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<UserDto> updateProfile(UpdateProfileRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserDto(
      userId: _currentUser.userId,
      email: _currentUser.email,
      nickname: request.nickname ?? _currentUser.nickname,
      profileImageUrl: request.profileImageUrl ?? _currentUser.profileImageUrl,
      userTag: _currentUser.userTag,
      createdAt: _currentUser.createdAt,
    );

    return _currentUser;
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}