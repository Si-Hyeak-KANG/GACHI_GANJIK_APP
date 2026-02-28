import '../album_remote_source.dart';
import '../../../models/album/album_dto.dart';
import '../../../models/album/create_album_request.dart';
import '../../../models/album/join_album_request.dart';
import '../../../models/album/update_album_request.dart';
import '../../../../../core/network/network_exception.dart';

class MockAlbumRemoteSource implements AlbumRemoteSource {
  static const String _currentUserId = 'user-uuid-1';

  final List<AlbumDto> _albums = [
    AlbumDto(
      id: 'album-uuid-4',
      title: '마크방범대',
      categories: ['친구','모임'],
      eventStartDate: '2025-01-27',
      eventEndDate: null,
      coverImageUrl: 'https://cdn2.colley.kr/item_340092_1_0_title_0.jpeg',
      inviteCode: 'TEST123',
      photoCount: 0,
      memberCount: 4,
      createdAt: '2025-01-18T10:00:00Z',
      updatedAt: null,
      ownerId: 'user-uuid-1',
      role: 'OWNER',
      currentUserId: _currentUserId,
      isAdmin: false,
    ),
    AlbumDto(
      id: 'album-uuid-1',
      title: '우리의 결혼식',
      categories: ['결혼'],
      eventStartDate: '2026-10-27',
      eventEndDate: '2026-10-27',
      // 웨딩 이미지
      coverImageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
      inviteCode: 'WD2025A',
      photoCount: 24,
      memberCount: 15,
      createdAt: '2025-04-18T10:00:00Z',
      updatedAt: null,
      ownerId: 'user-uuid-1',
      role: 'OWNER',
      currentUserId: _currentUserId,
      isAdmin: false,
    ),
    AlbumDto(
      id: 'album-uuid-2',
      title: '제주 여행 추억',
      categories: ['여행', '친구', '기록'],
      eventStartDate: '2025-01-27',
      eventEndDate: '2025-12-27',
      // 제주 자연 이미지
      coverImageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800&q=80',
      inviteCode: 'JJ03B2',
      photoCount: 48,
      memberCount: 6,
      createdAt: '2025-03-20T15:30:00Z',
      updatedAt: null,
      ownerId: 'user-uuid-2',
      role: 'MEMBER',
      currentUserId: _currentUserId,
      isAdmin: false,
    ),
    AlbumDto(
      id: 'album-uuid-3',
      title: '세바독',
      categories: ['모임', '독서'],
      eventStartDate: '2022-03-27',
      eventEndDate: null,
      // 커버 없음 (그라디언트 표시)
      coverImageUrl: null,
      inviteCode: 'MT14C3',
      photoCount: 12,
      memberCount: 8,
      createdAt: '2022-02-14T09:00:00Z',
      updatedAt: null,
      ownerId: 'user-uuid-1',
      role: 'OWNER',
      currentUserId: _currentUserId,
      isAdmin: false,
    ),
  ];

  int _nextId = 5;

  @override
  Future<List<AlbumDto>> getAlbums() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_albums);
  }

  @override
  Future<AlbumDto> getAlbum(String albumId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final found = _albums.where((a) => a.id == albumId);
    if (found.isEmpty) {
      throw NetworkException(
        message: '앨범을 찾을 수 없습니다',
        type: NetworkExceptionType.notFound,
        statusCode: 404,
        errorCode: 'ALBUM_NOT_FOUND',
      );
    }
    return found.first;
  }

  @override
  Future<AlbumDto> createAlbum(CreateAlbumRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    final newAlbum = AlbumDto(
      id: 'album-uuid-$_nextId',
      title: request.title,
      categories: request.categories,
      eventStartDate: request.eventStartDate,
      eventEndDate: request.eventEndDate,
      coverImageUrl: null,
      inviteCode: _generateInviteCode(),
      photoCount: 0,
      memberCount: 1,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: null,
      ownerId: _currentUserId,
      role: 'OWNER',
      currentUserId: _currentUserId,
      isAdmin: false,
    );

    _albums.insert(0, newAlbum);
    _nextId++;
    return newAlbum;
  }

  @override
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    final found = _albums.where(
          (a) => a.inviteCode.toUpperCase() == request.inviteCode.toUpperCase(),
    );

    if (found.isEmpty) {
      throw NetworkException(
        message: '유효하지 않은 초대 코드입니다',
        type: NetworkExceptionType.notFound,
        statusCode: 404,
        errorCode: 'INVALID_INVITE_CODE',
      );
    }

    final album = found.first;
    if (album.currentUserId == _currentUserId && album.role != 'GUEST') {
      throw NetworkException(
        message: '이미 참여 중인 앨범입니다',
        type: NetworkExceptionType.conflict,
        statusCode: 409,
        errorCode: 'ALREADY_JOINED',
      );
    }

    return album;
  }

  @override
  Future<AlbumDto> updateAlbum(String albumId, UpdateAlbumRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _albums.indexWhere((a) => a.id == albumId);
    if (index == -1) {
      throw NetworkException(
        message: '앨범을 찾을 수 없습니다',
        type: NetworkExceptionType.notFound,
        statusCode: 404,
        errorCode: 'ALBUM_NOT_FOUND',
      );
    }

    final existing = _albums[index];
    final updated = AlbumDto(
      id: existing.id,
      title: request.title ?? existing.title,
      categories: request.categories ?? existing.categories,
      eventStartDate: request.eventStartDate ?? existing.eventStartDate,
      eventEndDate: request.eventEndDate ?? existing.eventEndDate,
      coverImageUrl: existing.coverImageUrl,
      inviteCode: existing.inviteCode,
      photoCount: existing.photoCount,
      memberCount: existing.memberCount,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      ownerId: existing.ownerId,
      role: existing.role,
      currentUserId: existing.currentUserId,
      isAdmin: existing.isAdmin,
    );

    _albums[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _albums.removeWhere((a) => a.id == albumId);
  }

  @override
  Future<void> leaveAlbum(String albumId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _albums.removeWhere((a) => a.id == albumId);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final now = DateTime.now();
    return '${chars[now.second % chars.length]}'
        '${chars[now.millisecond % chars.length]}'
        '${now.year.toString().substring(2)}'
        '${chars[_nextId % chars.length]}';
  }
}