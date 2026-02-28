import '../photo_remote_source.dart';
import '../../../models/photo/photo_dto.dart';
import '../../../models/photo/upload_photo_request.dart';
import '../../../../../core/network/network_exception.dart';

class MockPhotoRemoteSource implements PhotoRemoteSource {
  static const String _currentUserId = 'user-uuid-1';
  static const String _currentUserNickname = '석스키';

  final Map<String, List<PhotoDto>> _photosByAlbum = {
    'album-uuid-1': [
      PhotoDto(
        id: 'photo-uuid-1',
        albumId: 'album-uuid-1',
        imageUrl: 'https://via.placeholder.com/400x600/FFE4C9',
        thumbnailUrl: 'https://via.placeholder.com/300x300/FFE4C9',
        message: '정말 행복한 순간이었어요',
        photoDate: '2025-04-18',
        uploaderId: 'user-uuid-1',
        uploaderNickname: '석스키',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-18T14:30:00Z',
        likeCount: 5,
        commentCount: 1,
      ),
      PhotoDto(
        id: 'photo-uuid-2',
        albumId: 'album-uuid-1',
        imageUrl: 'https://via.placeholder.com/400x600/D4E8FF',
        thumbnailUrl: 'https://via.placeholder.com/300x300/D4E8FF',
        message: '축하해!',
        photoDate: '2025-04-18',
        uploaderId: 'user-uuid-2',
        uploaderNickname: '민지',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-18T14:35:00Z',
        likeCount: 0,
        commentCount: 0,
      ),
      PhotoDto(
        id: 'photo-uuid-3',
        albumId: 'album-uuid-1',
        imageUrl: 'https://via.placeholder.com/400x600/E8D4FF',
        thumbnailUrl: 'https://via.placeholder.com/300x300/E8D4FF',
        message: '',
        photoDate: '2025-04-18',
        uploaderId: 'user-uuid-3',
        uploaderNickname: '준혁',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-18T14:40:00Z',
        likeCount: 0,
        commentCount: 1,
      ),
      PhotoDto(
        id: 'photo-uuid-5',
        albumId: 'album-uuid-1',
        imageUrl: 'https://via.placeholder.com/400x600/FFD4D4',
        thumbnailUrl: 'https://via.placeholder.com/300x300/FFD4D4',
        message: '리허설 날!',
        photoDate: '2025-04-17',
        uploaderId: 'user-uuid-1',
        uploaderNickname: '석스키',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-17T10:00:00Z',
        likeCount: 0,
        commentCount: 0,
      ),
      PhotoDto(
        id: 'photo-uuid-6',
        albumId: 'album-uuid-1',
        imageUrl: 'https://via.placeholder.com/400x600/FFF3D4',
        thumbnailUrl: 'https://via.placeholder.com/300x300/FFF3D4',
        message: '설렌다~',
        photoDate: '2025-04-17',
        uploaderId: 'user-uuid-2',
        uploaderNickname: '민지',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-17T10:30:00Z',
        likeCount: 0,
        commentCount: 0,
      ),
    ],
  };

  int _nextId = 100;

  @override
  Future<List<PhotoDto>> getAlbumPhotos(String albumId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _photosByAlbum[albumId] ?? [];
  }

  @override
  Future<PhotoDto> uploadPhoto(UploadPhotoRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    final newPhoto = PhotoDto(
      id: 'photo-uuid-$_nextId',
      albumId: request.albumId,
      imageUrl: request.imageUrl,
      thumbnailUrl: request.imageUrl,
      message: request.message,
      photoDate: request.photoDate,
      uploaderId: _currentUserId,
      uploaderNickname: _currentUserNickname,
      uploaderProfileImageUrl: null,
      createdAt: DateTime.now().toIso8601String(),
      likeCount: 0,
      commentCount: 0,
    );

    _photosByAlbum.putIfAbsent(request.albumId, () => []);
    _photosByAlbum[request.albumId]!.insert(0, newPhoto);
    _nextId++;
    return newPhoto;
  }

  @override
  Future<void> deletePhoto(String albumId, String photoId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final photos = _photosByAlbum[albumId];
    if (photos == null) return;

    final exists = photos.any((p) => p.id == photoId);
    if (!exists) {
      throw NetworkException(
        message: '사진을 찾을 수 없습니다',
        type: NetworkExceptionType.notFound,
        statusCode: 404,
        errorCode: 'PHOTO_NOT_FOUND',
      );
    }
    photos.removeWhere((p) => p.id == photoId);
  }
}