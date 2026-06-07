import '../../../../../core/network/network_exception.dart';
import '../../../models/guest/guest_dto.dart';
import '../guest_remote_source.dart';

class MockGuestRemoteSource implements GuestRemoteSource {
  final Map<String, GuestRegisterResponse> _guests = {};
  int _nextId = 1;

  @override
  Future<GuestRegisterResponse> registerGuest({
    required String guestKey,
    required String nickname,
    required String inviteCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_guests.containsKey(guestKey)) {
      throw NetworkException(
        message: '이미 사용 중인 GUEST ID입니다.',
        type: NetworkExceptionType.conflict,
        statusCode: 409,
        errorCode: 'GUEST_KEY_ALREADY_EXISTS',
      );
    }

    final response = GuestRegisterResponse(
      guestId: '$_nextId',
      guestKey: guestKey,
      nickname: nickname,
      albumId: 'album-uuid-1',
    );
    _guests[guestKey] = response;
    _nextId++;
    return response;
  }

  @override
  Future<GuestRestoreResponse> restoreGuest(String guestKey) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final guest = _guests[guestKey];
    if (guest == null) {
      throw NetworkException(
        message: 'GUEST 정보를 찾을 수 없습니다.',
        type: NetworkExceptionType.notFound,
        statusCode: 404,
        errorCode: 'GUEST_NOT_FOUND',
      );
    }

    return GuestRestoreResponse(
      guestId: guest.guestId,
      guestKey: guest.guestKey,
      nickname: guest.nickname,
    );
  }
}