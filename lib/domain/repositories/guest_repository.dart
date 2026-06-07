import '../../data/models/guest/guest_dto.dart';

abstract class GuestRepository {
  /// GUEST 등록 — SecureStorage에 guestKey, guestId 저장
  Future<GuestRegisterResponse> register({
    required String guestKey,
    required String nickname,
    required String inviteCode,
  });

  /// GUEST 복원 — SecureStorage 업데이트
  Future<GuestRestoreResponse> restore(String guestKey);

  /// GUEST 세션 초기화 (회원 전환 후 호출)
  Future<void> clearGuestSession();
}