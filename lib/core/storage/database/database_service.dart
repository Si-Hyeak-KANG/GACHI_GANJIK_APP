import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/storage/database/photo_local.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [PhotoLocalSchema],
      directory: dir.path,
      inspector: true, // 개발 중 Isar Inspector 사용 가능
    );
    return _isar!;
  }

  // 앨범의 모든 사진 조회
  static Future<List<PhotoLocal>> getPhotosByAlbum(int albumId) async {
    final isar = await instance;
    return isar.photoLocals
        .filter()
        .albumIdEqualTo(albumId)
        .sortByUploadedAtDesc()
        .findAll();
  }

  // 사진 저장
  static Future<void> savePhoto(PhotoLocal photo) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.photoLocals.put(photo);
    });
  }

  // 사진 삭제
  static Future<void> deletePhoto(int id) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.photoLocals.delete(id);
    });
  }

  // 업로드 대기 중인 사진 조회 (Phase 6 동기화에서 사용)
  static Future<List<PhotoLocal>> getPendingPhotos() async {
    final isar = await instance;
    return isar.photoLocals
        .filter()
        .statusEqualTo('pending')
        .findAll();
  }
}