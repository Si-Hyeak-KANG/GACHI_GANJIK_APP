import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'album_local.dart';
import 'photo_local.dart';
import 'like_local.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        AlbumLocalSchema,
        PhotoLocalSchema,
        LikeLocalSchema,
      ],
      directory: dir.path,
      inspector: true,
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

  // 대기 중인 사진 조회
  static Future<List<PhotoLocal>> getPendingPhotos() async {
    final isar = await instance;
    return isar.photoLocals
        .filter()
        .statusEqualTo('pending')
        .sortByUploadedAtDesc()
        .findAll();
  }

  // 좋아요 상태 확인
  static Future<bool> isLiked(int photoId, String userId) async {
    final isar = await instance;
    final like = await isar.likeLocals
        .filter()
        .photoIdEqualTo(photoId)
        .and()
        .userIdEqualTo(userId)
        .findFirst();
    return like != null;
  }
  // 좋아요 추가
  static Future<void> addLike(int photoId, String userId) async {
    final isar = await instance;
    final like = LikeLocal()
      ..photoId = photoId
      ..userId = userId
      ..likedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.likeLocals.put(like);
    });
  }

  // 좋아요 취소
  static Future<void> removeLike(int photoId, String userId) async {
    final isar = await instance;
    final like = await isar.likeLocals
        .filter()
        .photoIdEqualTo(photoId)
        .and()
        .userIdEqualTo(userId)
        .findFirst();

    if (like != null) {
      await isar.writeTxn(() async {
        await isar.likeLocals.delete(like.id);
      });
    }
  }

  // 사진의 총 좋아요 수 (로컬)
  static Future<int> getLikeCount(int photoId) async {
    final isar = await instance;
    return isar.likeLocals.filter().photoIdEqualTo(photoId).count();
  }

  // 모든 앨범 조회
  static Future<List<AlbumLocal>> getAllAlbums() async {
    final isar = await instance;
    return isar.albumLocals.where().sortByCreatedAtDesc().findAll();
  }

  // 앨범 저장
  static Future<void> saveAlbum(AlbumLocal album) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.albumLocals.put(album);
    });
  }

  // 앨범 삭제
  static Future<void> deleteAlbum(int id) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.albumLocals.delete(id);
    });
  }

  // 앨범 ID로 조회
  static Future<AlbumLocal?> getAlbumById(int albumId) async {
    final isar = await instance;
    return isar.albumLocals.filter().albumIdEqualTo(albumId).findFirst();
  }

  // 전체 데이터 삭제 (회원탈퇴용)
  static Future<void> clearAll() async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.albumLocals.clear();
      await isar.photoLocals.clear();
      await isar.likeLocals.clear();
    });
  }
}