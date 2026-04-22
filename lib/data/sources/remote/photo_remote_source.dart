import '../../models/photo/photo_dto.dart';
import '../../models/photo/upload_photo_request.dart';

abstract class PhotoRemoteSource {
  /// 앨범 사진 목록 조회 (6.2)
  Future<List<PhotoDto>> getAlbumPhotos(String albumId);

  /// 사진 업로드 (Firebase URL → 서버 저장) (6.3)
  Future<PhotoDto> uploadPhoto(UploadPhotoRequest request);

  /// 사진 삭제 (6.4) - 업로더만
  Future<void> deletePhoto(String albumId, String photoId);

  Future<void> updatePhotoMessage(String albumId, String photoId, String message);
}