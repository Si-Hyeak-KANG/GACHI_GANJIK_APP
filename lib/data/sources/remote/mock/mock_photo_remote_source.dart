import '../photo_remote_source.dart';
import '../../../models/photo/photo_dto.dart';
import '../../../models/photo/upload_photo_request.dart';

class MockPhotoRemoteSource implements PhotoRemoteSource {
  // Mock 데이터 (JSX SAMPLE_MOMENTS 기반)
  final Map<int, List<PhotoDto>> _photosByAlbum = {
    1: [
      // 2025.04.18
      PhotoDto(
        id: 1,
        albumId: 1,
        imageUrl: 'https://via.placeholder.com/400x600/FFE4C9',
        message: '정말 행복한 순간이었어요',
        uploader: '석스키',
        uploadedAt: '2025.04.18 14:30',
        likeCount: 5,
        comments: [
          CommentDto(user: '민지', text: '너무 예뻐!'),
        ],
      ),
      PhotoDto(
        id: 2,
        albumId: 1,
        imageUrl: 'https://via.placeholder.com/400x600/D4E8FF',
        message: '축하해!',
        uploader: '민지',
        uploadedAt: '2025.04.18 14:35',
      ),
      PhotoDto(
        id: 3,
        albumId: 1,
        imageUrl: 'https://via.placeholder.com/400x600/E8D4FF',
        message: '',
        uploader: '준혁',
        uploadedAt: '2025.04.18 14:40',
        comments: [
          CommentDto(user: '석스키', text: '고마워 준혁아'),
        ],
      ),
      // 2025.04.17
      PhotoDto(
        id: 5,
        albumId: 1,
        imageUrl: 'https://via.placeholder.com/400x600/FFD4D4',
        message: '리허설 날!',
        uploader: '석스키',
        uploadedAt: '2025.04.17 10:00',
      ),
      PhotoDto(
        id: 6,
        albumId: 1,
        imageUrl: 'https://via.placeholder.com/400x600/FFF3D4',
        message: '설렌다~',
        uploader: '민지',
        uploadedAt: '2025.04.17 10:30',
      ),
    ],
  };

  int _nextId = 100;

  @override
  Future<List<PhotoDto>> getAlbumPhotos(int albumId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _photosByAlbum[albumId] ?? [];
  }

  @override
  Future<PhotoDto> uploadPhoto(UploadPhotoRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    final newPhoto = PhotoDto(
      id: _nextId++,
      albumId: request.albumId,
      imageUrl: request.imageUrl,
      message: request.message,
      uploader: '나', // Phase 1 AuthController에서 가져와야 하지만 간단히 '나'로
      uploadedAt: _formatNow(),
    );

    // 목록에 추가
    _photosByAlbum.putIfAbsent(request.albumId, () => []);
    _photosByAlbum[request.albumId]!.insert(0, newPhoto);

    return newPhoto;
  }

  String _formatNow() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}