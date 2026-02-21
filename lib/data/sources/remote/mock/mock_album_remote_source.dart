import '../album_remote_source.dart';
import '../../../models/album/album_dto.dart';
import '../../../models/album/create_album_request.dart';
import '../../../models/album/join_album_request.dart';
import '../../../../../core/network/network_exception.dart';

class MockAlbumRemoteSource implements AlbumRemoteSource {
  final List<AlbumDto> _albums = [
    AlbumDto(
      id: 1,
      title: '우리의 결혼식',
      categories: ['결혼'],
      eventStartDate: '2026.10.27',
      eventEndDate: '2026.10.27',
      coverImage: null,
      inviteCode: 'WD2025A',
      photoCount: 24,
      memberCount: 15,
      createdAt: '2025.04.18',
    ),
    AlbumDto(
      id: 2,
      title: '제주 여행 추억',
      categories: ['여행','친구','기록'],
      eventStartDate: '2025.01.27',
      eventEndDate: '2025.12.27',
      coverImage: null,
      inviteCode: 'JJ03B2',
      photoCount: 48,
      memberCount: 6,
      createdAt: '2025.03.20',
    ),
    AlbumDto(
      id: 3,
      title: '세바독',
      categories: ['모임', '독서'],
      eventStartDate: '2022.03.27',
        eventEndDate: null,
      coverImage: null,
      inviteCode: 'MT14C3',
      photoCount: 12,
      memberCount: 8,
      createdAt: '2022.02.14'
    ),
  ];

  int _nextId = 4;

  @override
  Future<List<AlbumDto>> getAlbums() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_albums);
  }

  @override
  Future<AlbumDto> createAlbum(CreateAlbumRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    final newAlbum = AlbumDto(
      id: _nextId++,
      title: request.title,
      categories: request.categories,
      eventStartDate: request.eventStartDate,
      eventEndDate: request.eventEndDate,
      coverImage: null,
      inviteCode: _generateInviteCode(),
      photoCount: 0,
      memberCount: 1,
      createdAt: _formatToday(),
    );

    _albums.insert(0, newAlbum); // 최신 앨범을 맨 앞에
    return newAlbum;
  }

  @override
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    // 존재하는 코드인지 확인
    final found = _albums.where(
          (a) => a.inviteCode.toUpperCase() == request.inviteCode.toUpperCase(),
    );

    if (found.isEmpty) {
      throw NetworkException(
        message: '유효하지 않은 초대 코드입니다',
        type: NetworkExceptionType.badRequest,
        statusCode: 400,
      );
    }

    // 이미 참여한 앨범 시뮬레이션 (첫 번째 앨범)
    if (found.first.id == 1) {
      throw NetworkException(
        message: '이미 참여 중인 사진첩입니다',
        type: NetworkExceptionType.badRequest,
        statusCode: 400,
      );
    }

    return found.first;
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final now = DateTime.now();
    return '${chars[now.second % chars.length]}'
        '${chars[now.millisecond % chars.length]}'
        '${now.year.toString().substring(2)}'
        '${chars[_nextId % chars.length]}';
  }

  String _formatToday() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }
}