import '../../core/storage/secure_storage.dart';
import '../../domain/repositories/guest_repository.dart';
import '../models/guest/guest_dto.dart';
import '../sources/remote/guest_remote_source.dart';

class GuestRepositoryImpl implements GuestRepository {
  final GuestRemoteSource _remoteSource;
  final SecureStorage _secureStorage;

  GuestRepositoryImpl({
    required GuestRemoteSource remoteSource,
    required SecureStorage secureStorage,
  })  : _remoteSource = remoteSource,
        _secureStorage = secureStorage;

  @override
  Future<GuestRegisterResponse> register({
    required String guestKey,
    required String nickname,
    required String inviteCode,
  }) async {
    final response = await _remoteSource.registerGuest(
      guestKey: guestKey,
      nickname: nickname,
      inviteCode: inviteCode,
    );
    await _secureStorage.saveGuestKey(response.guestKey);
    await _secureStorage.saveGuestId(response.guestId);
    return response;
  }

  @override
  Future<GuestRestoreResponse> restore(String guestKey) async {
    final response = await _remoteSource.restoreGuest(guestKey);
    await _secureStorage.saveGuestKey(response.guestKey);
    await _secureStorage.saveGuestId(response.guestId);
    return response;
  }

  @override
  Future<void> clearGuestSession() async {
    await _secureStorage.clearGuestKey();
    await _secureStorage.clearGuestId();
  }
}