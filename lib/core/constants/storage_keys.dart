/// SecureStorage & SharedPreferences 키 상수
/// 기존 파일에 guestKey 추가
class StorageKeys {
  StorageKeys._();

  // 기존 토큰 키 (변경 없음)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  // 비회원(GUEST) 키 ← 추가
  static const String guestKey = 'guest_key';
  static const String guestId  = 'guest_id';

  // SharedPreferences
  static const String userId = 'user_id';
  static const String isFirstLaunch = 'is_first_launch';

  static const String deviceId = 'device_id';
}