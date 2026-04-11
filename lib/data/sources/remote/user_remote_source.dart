import '../../models/auth/user_dto.dart';
import '../../models/user/update_profile_request.dart';

abstract class UserRemoteSource {
  Future<UserDto> getCurrentUser();
  Future<UserDto> updateProfile(UpdateProfileRequest request);
  Future<String> updateProfileImage(String profileImageUrl);
  Future<void> deleteAccount();
}