import '../../models/guest/guest_dto.dart';

abstract class GuestRemoteSource {
  /// POST /api/v1/guests/register
  Future<GuestRegisterResponse> registerGuest({
    required String guestKey,
    required String nickname,
    required String inviteCode,
  });

  /// POST /api/v1/guests/restore
  Future<GuestRestoreResponse> restoreGuest(String guestKey);
}