import '../../core/storage/database/database_service.dart';
import '../../core/storage/database/album_local.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/album_repository.dart';
import '../models/album/create_album_request.dart';
import '../models/album/join_album_request.dart';
import '../sources/remote/album_remote_source.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumRemoteSource _remoteSource;

  AlbumRepositoryImpl({required AlbumRemoteSource remoteSource})
      : _remoteSource = remoteSource;

  @override
  Future<List<Album>> getAlbums() async {
    try {
      // 서버에서 가져오기 시도
      final dtos = await _remoteSource.getAlbums();
      final albums = dtos.map((dto) => dto.toEntity()).toList();
      await _saveAlbumsToLocal(albums); // 로컬 DB에 저장 (캐싱)
      return albums;
    } catch (e) {
      // 네트워크 오류 시 로컬 DB에서 조회
      print('서버 조회 실패, 로컬 DB 사용: $e');
      return await _getAlbumsFromLocal();
    }
  }

  @override
  Future<Album> createAlbum({
    required String title,
    String? category,
    String? eventDate,
  }) async {

    print('🔵 AlbumRepositoryImpl.createAlbum 시작');
    print('  title: $title');
    print('  category: $category');
    print('  eventDate: $eventDate');

    try {
      final request = CreateAlbumRequest(
        title: title,
        category: category,
        eventDate: eventDate,
      );

      print('🔵 Request 생성 완료');

      final dto = await _remoteSource.createAlbum(request);
      print('🔵 Remote Source 호출 성공');
      print('  dto.id: ${dto.id}');
      print('  dto.createdAt: ${dto.createdAt}');

      final album = dto.toEntity();
      print('🔵 Entity 변환 완료');

      print('🔵 로컬 DB 저장 시작');
      await _saveAlbumToLocal(album);
      print('🔵 로컬 DB 저장 완료');

      return album;
    } catch (e, stackTrace) {
      print('🔴 AlbumRepositoryImpl.createAlbum 에러: $e');
      print('🔴 StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<Album> joinAlbum(String inviteCode) async {
    final request = JoinAlbumRequest(inviteCode: inviteCode);

    final dto = await _remoteSource.joinAlbum(request);
    final album = dto.toEntity();

    // 로컬 DB에 저장
    await _saveAlbumToLocal(album);

    return album;
  }

  Future<void> _saveAlbumsToLocal(List<Album> albums) async {
    for (final album in albums) {
      await _saveAlbumToLocal(album);
    }
  }

  Future<void> _saveAlbumToLocal(Album album) async {
    try {
      print('  🟢 _saveAlbumToLocal 시작');
      print('    album.createdAt 원본: "${album.createdAt}"');

      // ✅ 날짜 파싱 - "2026.02.21" 형식 처리
      DateTime createdAt;
      try {
        final dateStr = album.createdAt.trim();

        // "2026.02.21" → "2026-02-21"
        if (dateStr.contains('.')) {
          final datePart = dateStr.replaceAll('.', '-');
          print('    변환된 날짜 문자열: "$datePart"');
          createdAt = DateTime.parse(datePart);
        }
        // ISO 8601 형식 (예: "2026-02-21T10:30:00")
        else if (dateStr.contains('-')) {
          createdAt = DateTime.parse(dateStr);
        }
        // 기타 형식 - 현재 시간 사용
        else {
          print('    알 수 없는 날짜 형식, 현재 시간 사용');
          createdAt = DateTime.now();
        }

        print('    파싱 성공: $createdAt');
      } catch (e) {
        print('  ⚠️ 날짜 파싱 실패, 현재 시간 사용: $e');
        createdAt = DateTime.now();
      }

      final local = AlbumLocal()
        ..albumId = album.id
        ..title = album.title
        ..category = album.category
        ..eventDate = album.eventDate
        ..coverImage = album.coverImage
        ..inviteCode = album.inviteCode
        ..photoCount = album.photoCount
        ..memberCount = album.memberCount
        ..createdAt = createdAt
        ..lastSyncedAt = DateTime.now()
        ..syncStatus = 'synced';

      await DatabaseService.saveAlbum(local);
      print('  🟢 _saveAlbumToLocal 완료');
    } catch (e, stackTrace) {
      print('  🔴 _saveAlbumToLocal 에러: $e');
      print('  🔴 StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Album>> _getAlbumsFromLocal() async {
    final locals = await DatabaseService.getAllAlbums();
    return locals.map(_localToEntity).toList();
  }

  Album _localToEntity(AlbumLocal local) {
    return Album(
      id: local.albumId,
      title: local.title,
      category: local.category,
      eventDate: local.eventDate,
      coverImage: local.coverImage,
      inviteCode: local.inviteCode,
      photoCount: local.photoCount,
      memberCount: local.memberCount,
      createdAt: local.createdAt.toIso8601String(),
    );
  }
}