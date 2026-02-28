import '../../../../../core/network/dio_client.dart';
import '../guest_remote_source.dart';

class RealGuestRemoteSource implements GuestRemoteSource {
  final DioClient _dioClient;

  RealGuestRemoteSource({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<GuestResponse> enterAsGuest(GuestEnterRequest request) async {
    final response = await _dioClient.post(
      '/guest/enter',
      data: request.toJson(),
    );
    return GuestResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}