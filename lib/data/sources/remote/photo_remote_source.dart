import '../../models/photo/photo_dto.dart';
import '../../models/photo/upload_photo_request.dart';

abstract class PhotoRemoteSource {
  Future<List<PhotoDto>> getAlbumPhotos(int albumId);
  Future<PhotoDto> uploadPhoto(UploadPhotoRequest request);
}