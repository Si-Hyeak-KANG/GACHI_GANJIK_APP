import '../photo_remote_source.dart';
import '../../../models/photo/photo_dto.dart';
import '../../../models/photo/upload_photo_request.dart';
import '../../../../../core/network/network_exception.dart';

class MockPhotoRemoteSource implements PhotoRemoteSource {
  static const String _currentUserId = 'user-uuid-1';
  static const String _currentUserNickname = '석스키';

  final Map<String, List<PhotoDto>> _photosByAlbum = {
    'album-uuid-1': [
      // ── moment-uuid-1 : 석스키, 사진 1장 ──
      PhotoDto(
        id: 'photo-uuid-1',
        albumId: 'album-uuid-1',
        momentId: 'moment-uuid-1',
        imageUrl: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=800&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=400&q=70',
        message: '정말 행복한 순간이었어요 🌸',
        photoDate: '2025-04-18',
        uploaderId: 'user-uuid-1',
        uploaderNickname: '석스키',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-18T14:30:00Z',
      ),
      // ── moment-uuid-2 : 민지, 사진 2장 (가로 스크롤 확인용, 코멘트 공유) ──
      PhotoDto(
        id: 'photo-uuid-2',
        albumId: 'album-uuid-1',
        momentId: 'moment-uuid-2',
        imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=400&q=70',
        message: '웨딩 촬영 너무 예뻤어, 축하해 💍',
        photoDate: '2025-04-18',
        uploaderId: 'user-uuid-2',
        uploaderNickname: '민지',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-18T14:35:00Z',
      ),
      PhotoDto(
        id: 'photo-uuid-4',
        albumId: 'album-uuid-1',
        momentId: 'moment-uuid-2',
        imageUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=800&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=400&q=70',
        message: '웨딩 촬영 너무 예뻤어, 축하해 💍',
        photoDate: '2025-04-18',
        uploaderId: 'user-uuid-2',
        uploaderNickname: '민지',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-18T14:36:00Z',
      ),
      // ── moment-uuid-3 : 준혁, 사진 1장 (코멘트 없음 케이스) ──
      PhotoDto(
        id: 'photo-uuid-3',
        albumId: 'album-uuid-1',
        momentId: 'moment-uuid-3',
        imageUrl: 'https://images.unsplash.com/photo-1529636798458-92182e662485?w=800&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1529636798458-92182e662485?w=400&q=70',
        message: null,
        photoDate: '2025-04-18',
        uploaderId: 'user-uuid-3',
        uploaderNickname: '준혁',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-18T14:40:00Z',
      ),
      // ── moment-uuid-4 : 석스키, 사진 1장 ──
      PhotoDto(
        id: 'photo-uuid-5',
        albumId: 'album-uuid-1',
        momentId: 'moment-uuid-4',
        imageUrl: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=400&q=70',
        message: '리허설 날! 드디어 내일이야 🥹',
        photoDate: '2025-04-17',
        uploaderId: 'user-uuid-1',
        uploaderNickname: '석스키',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-17T10:00:00Z',
      ),
      // ── moment-uuid-5 : 민지, 사진 1장 ──
      PhotoDto(
        id: 'photo-uuid-6',
        albumId: 'album-uuid-1',
        momentId: 'moment-uuid-5',
        imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400&q=70',
        message: '설레서 잠 못 자겠다~',
        photoDate: '2025-04-17',
        uploaderId: 'user-uuid-2',
        uploaderNickname: '민지',
        uploaderProfileImageUrl: null,
        createdAt: '2025-04-17T10:30:00Z',
      ),
    ],
    'album-uuid-2': [
      PhotoDto(
        id: 'photo-uuid-7',
        albumId: 'album-uuid-2',
        momentId: 'moment-uuid-6',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=70',
        message: '한라산 정상 🏔️',
        photoDate: '2025-06-15',
        uploaderId: 'user-uuid-1',
        uploaderNickname: '석스키',
        uploaderProfileImageUrl: null,
        createdAt: '2025-06-15T09:00:00Z',
      ),
      PhotoDto(
        id: 'photo-uuid-8',
        albumId: 'album-uuid-2',
        momentId: 'moment-uuid-7',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=70',
        message: '성산일출봉 앞에서 🌅',
        photoDate: '2025-06-15',
        uploaderId: 'user-uuid-2',
        uploaderNickname: '민지',
        uploaderProfileImageUrl: null,
        createdAt: '2025-06-15T11:00:00Z',
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
      momentId: request.momentId,
      imageUrl: request.imageUrl,
      thumbnailUrl: request.imageUrl,
      message: request.message,
      photoDate: request.photoDate,
      uploaderId: _currentUserId,
      uploaderNickname: _currentUserNickname,
      uploaderProfileImageUrl: null,
      createdAt: DateTime.now().toIso8601String(),
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

  @override
  Future<void> updatePhotoMessage(String albumId, String photoId, String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final photos = _photosByAlbum[albumId];
    if (photos == null) return;
    final index = photos.indexWhere((p) => p.id == photoId);
    if (index == -1) return;
    final photo = photos[index];
    photos[index] = PhotoDto(
      id: photo.id,
      albumId: photo.albumId,
      momentId: photo.momentId,
      imageUrl: photo.imageUrl,
      thumbnailUrl: photo.thumbnailUrl,
      message: message.isEmpty ? null : message,
      photoDate: photo.photoDate,
      uploaderId: photo.uploaderId,
      uploaderNickname: photo.uploaderNickname,
      uploaderProfileImageUrl: photo.uploaderProfileImageUrl,
      createdAt: photo.createdAt,
    );
  }
}