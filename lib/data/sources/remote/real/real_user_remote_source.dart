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
    final response = await _dioClient.patch(
      '/users/me',
      data: request.toJson(),
    );
    return UserDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAccount() async {
    await _dioClient.delete('/users/me');
  }
}