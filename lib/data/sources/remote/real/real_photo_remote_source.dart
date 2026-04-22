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
    final response = await _dioClient.get(
      '/albums/$albumId/photos',
      queryParameters: {'page': 0, 'size': 50},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final moments = data['moments'] as List<dynamic>? ?? [];

    final photos = <PhotoDto>[];
    for (final moment in moments) {
      final photoList =
          (moment as Map<String, dynamic>)['photos'] as List<dynamic>? ?? [];
      for (final photo in photoList) {
        final photoMap = photo as Map<String, dynamic>;
        photos.add(PhotoDto.fromJson({...photoMap, 'albumId': albumId}));
      }
    }
    return photos;
  }

  @override
  Future<PhotoDto> uploadPhoto(UploadPhotoRequest request) async {
    final response = await _dioClient.post(
      '/albums/${request.albumId}/photos',
      data: request.toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final photoList = data['photos'] as List<dynamic>;
    return PhotoDto.fromJson({
      ...(photoList.first as Map<String, dynamic>),
      'albumId': request.albumId,
    });
  }

  @override
  Future<void> deletePhoto(String albumId, String photoId) async {
    await _dioClient.delete('/albums/$albumId/photos/$photoId');
  }

  @override
  Future<void> updatePhotoMessage(String albumId, String photoId, String message) async {
    await _dioClient.patch(
      '/albums/$albumId/photos/$photoId',
      data: {'message': message},
    );
  }
}