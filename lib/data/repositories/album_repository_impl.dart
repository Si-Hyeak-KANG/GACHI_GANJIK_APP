import '../../core/storage/database/database_service.dart';
import '../../core/storage/database/album_local.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/album_repository.dart';
import '../models/album/create_album_request.dart';
import '../models/album/join_album_request.dart';
import '../sources/remote/album_remote_source.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumRemoteSource _remoteSource;

  // ✅ 현재 사용자 ID (추후 AuthController에서 주입)
  String get _currentUserId => 'user-uuid-1';  // TODO: AuthController

  AlbumRepositoryImpl({required AlbumRemoteSource remoteSource})
      : _remoteSource = remoteSource;

  // ✅ 온라인 우선: 서버 → 로컬 저장 → 실패 시 로컬 조회
  @override
  Future<List<Album>> getAlbums() async {
    try {
      print('🔵 서버에서 앨범 목록 조회 시작');

      // 1. 서버에서 조회
      final dtos = await _remoteSource.getAlbums();
      print('🔵 서버 조회 성공: ${dtos.length}개');

      // 2. 엔티티 변환 (currentUserId 주입)
      final albums = dtos.map((dto) => dto.toEntity()).toList();

      // 3. 로컬 DB에 저장 (캐싱)
      await _saveAlbumsToLocal(albums);
      print('🔵 로컬 DB 캐싱 완료');

      return albums;
    } catch (e) {
      print('⚠️ 서버 조회 실패, 로컬 DB 사용: $e');

      // 4. 폴백: 로컬 DB에서 조회
      return await _getAlbumsFromLocal();
    }
  }

  @override
  Future<Album> getAlbum(String albumId) async {
    try {
      print('🔵 서버에서 앨범 상세 조회: $albumId');

      // TODO: API 구현 시 추가
      // final dto = await _remoteSource.getAlbum(albumId);
      // await _saveAlbumToLocal(dto.toEntity());
      // return dto.toEntity();

      // 임시: 로컬에서 조회
      return await _getAlbumFromLocal(albumId);
    } catch (e) {
      print('⚠️ 서버 조회 실패, 로컬 DB 사용: $e');
      return await _getAlbumFromLocal(albumId);
    }
  }

  @override
  Future<Album> createAlbum({
    required String title,
    required List<String> categories,
    required String eventStartDate,
    String? eventEndDate,
  }) async {
    print('🔵 AlbumRepositoryImpl.createAlbum 시작');
    print('  title: $title');
    print('  categories: $categories');
    print('  eventStartDate: $eventStartDate');
    print('  eventEndDate: $eventEndDate');

    try {
      final request = CreateAlbumRequest(
        title: title,
        categories: categories,
        eventStartDate: eventStartDate,
        eventEndDate: eventEndDate,
      );

      print('🔵 Request 생성 완료');

      // 1. 서버에 생성 요청
      final dto = await _remoteSource.createAlbum(request);
      print('🔵 서버 생성 성공: ${dto.id}');

      // 2. 엔티티 변환
      final album = dto.toEntity();
      print('🔵 Entity 변환 완료');

      // 3. 로컬 DB에 저장
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
    print('🔵 AlbumRepositoryImpl.joinAlbum: $inviteCode');

    try {
      final request = JoinAlbumRequest(inviteCode: inviteCode);

      // 1. 서버에 참여 요청
      final dto = await _remoteSource.joinAlbum(request);
      print('🔵 서버 참여 성공: ${dto.id}');

      // 2. 엔티티 변환
      final album = dto.toEntity();

      // 3. 로컬 DB에 저장
      await _saveAlbumToLocal(album);

      return album;
    } catch (e) {
      print('🔴 joinAlbum 에러: $e');
      rethrow;
    }
  }

  @override
  Future<Album> updateAlbum({
    required String albumId,
    required String title,
    required List<String> categories,
    required String eventStartDate,
    String? eventEndDate,
  }) async {
    // TODO: API 구현 시 추가
    throw UnimplementedError('앨범 수정 기능은 준비 중입니다');
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    // TODO: API 구현 시 추가
    throw UnimplementedError('앨범 삭제 기능은 준비 중입니다');
  }

  @override
  Future<void> leaveAlbum(String albumId) async {
    // TODO: API 구현 시 추가
    throw UnimplementedError('앨범 나가기 기능은 준비 중입니다');
  }

  // ========== Private Methods ==========

  Future<void> _saveAlbumsToLocal(List<Album> albums) async {
    for (final album in albums) {
      await _saveAlbumToLocal(album);
    }
  }

  Future<void> _saveAlbumToLocal(Album album) async {
    try {
      print('  🟢 _saveAlbumToLocal 시작: ${album.id}');

      final local = AlbumLocal()
        ..albumId = album.id
        ..title = album.title
        ..categoriesJson = album.categories.join(',')
        ..eventStartDate = album.eventStartDate
        ..eventEndDate = album.eventEndDate
        ..coverImageUrl = album.coverImageUrl
        ..inviteCode = album.inviteCode
        ..photoCount = album.photoCount
        ..memberCount = album.memberCount
        ..createdAt = album.createdAt
        ..updatedAt = album.updatedAt
        ..lastSyncedAt = DateTime.now()
        ..syncStatus = 'synced'
        ..ownerId = album.ownerId
        ..currentUserId = album.currentUserId
        ..role = album.role
        ..isAdmin = album.isAdmin;

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
    print('📦 로컬 DB에서 ${locals.length}개 앨범 조회');
    return locals.map(_localToEntity).toList();
  }

  Future<Album> _getAlbumFromLocal(String albumId) async {
    final local = await DatabaseService.getAlbum(albumId);
    if (local == null) {
      throw Exception('앨범을 찾을 수 없습니다: $albumId');
    }
    return _localToEntity(local);
  }

  Album _localToEntity(AlbumLocal local) {
    final categories = local.categoriesJson
        ?.split(',')
        .where((c) => c.isNotEmpty)
        .toList() ?? [];

    return Album(
      id: local.albumId,
      title: local.title,
      categories: categories,
      eventStartDate: local.eventStartDate ?? '',
      eventEndDate: local.eventEndDate,
      coverImageUrl: local.coverImageUrl,
      inviteCode: local.inviteCode,
      photoCount: local.photoCount,
      memberCount: local.memberCount,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      ownerId: local.ownerId,
      currentUserId: local.currentUserId,
      role: local.role,
      isAdmin: local.isAdmin,
    );
  }
}