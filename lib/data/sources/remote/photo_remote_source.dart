import '../../models/photo/photo_dto.dart';
import '../../models/photo/upload_photo_request.dart';

abstract class PhotoRemoteSource {
  /// 앨범의 사진 목록 조회
  Future<List<PhotoDto>> getAlbumPhotos(String albumId);  // ✅ String

  /// 사진 업로드
  Future<PhotoDto> uploadPhoto(UploadPhotoRequest request);
}