import '../../../../../core/network/dio_client.dart';
import '../../../models/photo/photo_dto.dart';
import '../../../models/photo/upload_photo_request.dart';
import '../photo_remote_source.dart';

class RealPhotoRemoteSource implements PhotoRemoteSource {
  final DioClient _dioClient;

  RealPhotoRemoteSource({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<PhotoDto>> getAlbumPhotos(String albumId) async {
    final response = await _dioClient.get('/albums/$albumId/photos');
    final data = response.data['data'] as Map<String, dynamic>;
    final list = data['photos'] as List<dynamic>;
    return list
        .map((e) => PhotoDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PhotoDto> uploadPhoto(UploadPhotoRequest request) async {
    final response = await _dioClient.post(
      '/albums/${request.albumId}/photos',
      data: request.toJson(),
    );
    return PhotoDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deletePhoto(String albumId, String photoId) async {
    await _dioClient.delete('/albums/$albumId/photos/$photoId');
  }
}