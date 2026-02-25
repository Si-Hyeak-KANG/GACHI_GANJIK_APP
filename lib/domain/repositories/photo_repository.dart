import 'dart:io';
import '../entities/photo.dart';
import '../entities/moment.dart';

abstract class PhotoRepository {
  /// 앨범의 사진 목록 조회 (Moments로 그룹화) - 온라인 우선
  Future<List<Moment>> getAlbumMoments(String albumId);  // ✅ String

  /// 사진 업로드
  Future<Photo> uploadPhoto({
    required String albumId,           // ✅ String
    required File imageFile,
    String? message,
    required String photoDate,         // ✅ 추가: YYYY-MM-DD
  });

  /// 사진 삭제
  Future<void> deletePhoto(String photoId);  // ✅ 추가
}