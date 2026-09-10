import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'album_local.dart';
import 'photo_local.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        AlbumLocalSchema,
        PhotoLocalSchema,
      ],
      directory: dir.path,
      inspector: true,
    );

    return _isar!;
  }

  // ========== Photo Methods ==========

  /// 앨범의 모든 사진 조회
  static Future<List<PhotoLocal>> getPhotosByAlbum(String albumId) async {  // ✅ String
    final isar = await instance;
    return isar.photoLocals
        .filter()
        .albumIdEqualTo(albumId)
        .sortByCreatedAtDesc()  // ✅ uploadedAt → createdAt
        .findAll();
  }

  /// 사진 저장 (UUID 기반)
  static Future<void> savePhoto(PhotoLocal photo) async {
    final isar = await instance;

    // ✅ photoId로 기존 사진 찾기
    final existing = await isar.photoLocals
        .filter()
        .photoIdEqualTo(photo.photoId)
        .findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        // 기존 사진 업데이트 (Isar ID 유지)
        photo.id = existing.id;
      }
      await isar.photoLocals.put(photo);
    });
  }

  /// 사진 삭제 (photoId 기반)
  static Future<void> deletePhoto(String photoId) async {  // ✅ String
    final isar = await instance;

    final photo = await isar.photoLocals
        .filter()
        .photoIdEqualTo(photoId)
        .findFirst();

    if (photo != null) {
      await isar.writeTxn(() async {
        await isar.photoLocals.delete(photo.id);
      });
    }
  }

  /// 대기 중인 사진 조회 (업로드 대기열)
  static Future<List<PhotoLocal>> getPendingPhotos() async {
    final isar = await instance;
    return isar.photoLocals
        .filter()
        .statusEqualTo('pending')
        .sortByCreatedAtDesc()  // ✅ uploadedAt → createdAt
        .findAll();
  }

  // ========== Album Methods ==========

  /// 모든 앨범 조회
  static Future<List<AlbumLocal>> getAllAlbums() async {
    final isar = await instance;
    return isar.albumLocals.where().sortByCreatedAtDesc().findAll();
  }

  /// 앨범 저장 (UUID 기반)
  static Future<void> saveAlbum(AlbumLocal album) async {
    final isar = await instance;

    // ✅ albumId로 기존 앨범 찾기
    final existing = await isar.albumLocals
        .filter()
        .albumIdEqualTo(album.albumId)
        .findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        // 기존 앨범 업데이트 (Isar ID 유지)
        album.id = existing.id;
      }
      await isar.albumLocals.put(album);
    });
  }

  /// 앨범 삭제 (albumId 기반)
  static Future<void> deleteAlbum(String albumId) async {  // ✅ String
    final isar = await instance;

    final album = await isar.albumLocals
        .filter()
        .albumIdEqualTo(albumId)
        .findFirst();

    if (album != null) {
      await isar.writeTxn(() async {
        await isar.albumLocals.delete(album.id);
      });
    }
  }

  /// 앨범 UUID로 조회 ✅ 추가
  static Future<AlbumLocal?> getAlbum(String albumId) async {
    final isar = await instance;
    return isar.albumLocals
        .filter()
        .albumIdEqualTo(albumId)
        .findFirst();
  }

  /// ✅ 하위 호환: int ID로 조회 (Deprecated)
  @Deprecated('Use getAlbum(String albumId) instead')
  static Future<AlbumLocal?> getAlbumById(int id) async {
    final isar = await instance;
    return isar.albumLocals.get(id);
  }

  // ========== Utility Methods ==========

  /// 전체 데이터 삭제 (회원탈퇴용)
  static Future<void> clearAll() async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.albumLocals.clear();
      await isar.photoLocals.clear();
    });
  }
}