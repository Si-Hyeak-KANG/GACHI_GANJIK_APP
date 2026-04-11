import '../../../../../core/network/dio_client.dart';
import '../../../models/auth/user_dto.dart';
import '../../../models/user/update_profile_request.dart';
import '../user_remote_source.dart';

class RealUserRemoteSource implements UserRemoteSource {
  final DioClient _dioClient;

  RealUserRemoteSource({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<UserDto> getCurrentUser() async {
    final response = await _dioClient.get('/users/me');
    return UserDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserDto> updateProfile(UpdateProfileRequest request) async {
    // PATCH 응답: { userId, nickname, updatedAt } — UserDto 전체 필드 부족
    // → PATCH 후 GET으로 최신 전체 프로필 재조회
    await _dioClient.patch('/users/me', data: request.toJson());
    return await getCurrentUser();
  }

  @override
  Future<String> updateProfileImage(String profileImageUrl) async {
    final response = await _dioClient.post(
      '/users/me/profile-image',
      data: {'profileImageUrl': profileImageUrl},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return data['profileImageUrl'] as String;
  }

  @override
  Future<void> deleteAccount() async {
    await _dioClient.delete('/auth/withdraw');
  }
}