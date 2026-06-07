import '../../../../../core/network/dio_client.dart';
import '../../../models/guest/guest_dto.dart';
import '../guest_remote_source.dart';

class RealGuestRemoteSource implements GuestRemoteSource {
  final DioClient _dioClient;

  RealGuestRemoteSource({required DioClient dioClient})
      : _dioClient = dioClient;

  /// POST /api/v1/guests/register
  @override
  Future<GuestRegisterResponse> registerGuest({
    required String guestKey,
    required String nickname,
    required String inviteCode,
  }) async {
    final response = await _dioClient.post(
      '/guests/register',
      data: {
        'guestKey': guestKey,
        'nickname': nickname,
        'inviteCode': inviteCode,
      },
    );
    return GuestRegisterResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  /// POST /api/v1/guests/restore
  @override
  Future<GuestRestoreResponse> restoreGuest(String guestKey) async {
    final response = await _dioClient.post(
      '/guests/restore',
      data: {'guestKey': guestKey},
    );
    return GuestRestoreResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}