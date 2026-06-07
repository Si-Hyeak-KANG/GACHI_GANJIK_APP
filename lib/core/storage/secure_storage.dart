import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ===================== Access Token =====================

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  // ===================== Refresh Token =====================

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  // ===================== 헬퍼: 토큰 한 번에 저장 =====================

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  // ===================== Guest Key (비회원) =====================

  Future<void> saveGuestKey(String guestKey) async {
    await _storage.write(key: StorageKeys.guestKey, value: guestKey);
  }

  Future<String?> getGuestKey() async {
    return await _storage.read(key: StorageKeys.guestKey);
  }

  Future<void> clearGuestKey() async {
    await _storage.delete(key: StorageKeys.guestKey);
  }

  Future<void> saveGuestId(String guestId) async {
    await _storage.write(key: StorageKeys.guestId, value: guestId);
  }

  Future<String?> getGuestId() async {
    return await _storage.read(key: StorageKeys.guestId);
  }

  Future<void> clearGuestId() async {
    await _storage.delete(key: StorageKeys.guestId);
  }

  // ===================== 전체 초기화 =====================

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}