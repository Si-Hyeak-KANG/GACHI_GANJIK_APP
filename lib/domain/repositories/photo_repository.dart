import 'dart:io';
import '../entities/photo.dart';
import '../entities/moment.dart';

abstract class PhotoRepository {
  /// 앨범의 사진 목록 조회 (업로드 배치 Moment로 그룹화) - 온라인 우선
  Future<List<Moment>> getAlbumMoments(String albumId);

  /// 사진 업로드
  /// [momentId] 같은 업로드 배치의 사진들은 동일한 momentId를 전달한다.
  Future<Photo> uploadPhoto({
    required String albumId,
    required File imageFile,
    String? message,
    required String photoDate,
    String? momentId,
  });

  /// 사진 삭제
  Future<void> deletePhoto(String photoId, {required String albumId, required String imageUrl});

  Future<void> updatePhotoMessage({
    required String albumId,
    required String photoId,
    required String message,
  });
}