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
      final momentMap = moment as Map<String, dynamic>;
      final momentId = momentMap['momentId']?.toString();
      final momentComment = momentMap['comment'] as String?;

      // 업로더 정보가 moment 레벨에 있을 수 있으므로 각 photo에 보강한다.
      final mUploaderId = momentMap['uploaderId'];
      final mUploaderNickname = momentMap['uploaderNickname'];
      final mUploaderProfile =
          momentMap['uploaderProfileImageUrl'] ?? momentMap['profileImageUrl'];

      final photoList = momentMap['photos'] as List<dynamic>? ?? [];
      for (final photo in photoList) {
        final photoMap = photo as Map<String, dynamic>;
        final photoHasProfile =
            (photoMap['uploaderProfileImageUrl'] ?? photoMap['profileImageUrl']) !=
                null;

        photos.add(PhotoDto.fromJson({
          ...photoMap,
          'albumId': albumId,
          if (momentId != null) 'momentId': momentId,
          if (momentComment != null) 'message': momentComment,
          // photo에 업로더 정보가 없을 때만 moment 레벨 값으로 채운다.
          if (photoMap['uploaderId'] == null && mUploaderId != null)
            'uploaderId': mUploaderId,
          if (photoMap['uploaderNickname'] == null && mUploaderNickname != null)
            'uploaderNickname': mUploaderNickname,
          if (!photoHasProfile && mUploaderProfile != null)
            'uploaderProfileImageUrl': mUploaderProfile,
        }));
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
      if (request.momentId != null) 'momentId': request.momentId,
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