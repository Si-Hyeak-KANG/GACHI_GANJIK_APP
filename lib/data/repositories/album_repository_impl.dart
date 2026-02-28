import '../../core/storage/database/album_local.dart';
import '../../core/storage/database/database_service.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/album_repository.dart';
import '../models/album/create_album_request.dart';
import '../models/album/join_album_request.dart';
import '../models/album/update_album_request.dart';
import '../sources/remote/album_remote_source.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumRemoteSource _remoteSource;

  AlbumRepositoryImpl({required AlbumRemoteSource remoteSource})
      : _remoteSource = remoteSource;

  @override
  Future<List<Album>> getAlbums() async {
    try {
      final dtos = await _remoteSource.getAlbums();
      final albums = dtos.map((dto) => dto.toEntity()).toList();
      await _saveAlbumsToLocal(albums);
      return albums;
    } catch (e) {
      return await _getAlbumsFromLocal();
    }
  }

  @override
  Future<Album> getAlbum(String albumId) async {
    try {
      final dto = await _remoteSource.getAlbum(albumId);
      final album = dto.toEntity();
      await _saveAlbumToLocal(album);
      return album;
    } catch (e) {
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
    final request = CreateAlbumRequest(
      title: title,
      categories: categories,
      eventStartDate: eventStartDate,
      eventEndDate: eventEndDate,
    );
    final dto = await _remoteSource.createAlbum(request);
    final album = dto.toEntity();
    await _saveAlbumToLocal(album);
    return album;
  }

  @override
  Future<Album> joinAlbum(String inviteCode) async {
    final request = JoinAlbumRequest(inviteCode: inviteCode);
    final dto = await _remoteSource.joinAlbum(request);
    final album = dto.toEntity();
    await _saveAlbumToLocal(album);
    return album;
  }

  @override
  Future<Album> updateAlbum({
    required String albumId,
    required String title,
    required List<String> categories,
    required String eventStartDate,
    String? eventEndDate,
  }) async {
    final request = UpdateAlbumRequest(
      title: title,
      categories: categories,
      eventStartDate: eventStartDate,
      eventEndDate: eventEndDate,
    );
    final dto = await _remoteSource.updateAlbum(albumId, request);
    final album = dto.toEntity();
    await _saveAlbumToLocal(album);
    return album;
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    await _remoteSource.deleteAlbum(albumId);
    await DatabaseService.deleteAlbum(albumId);
  }

  @override
  Future<void> leaveAlbum(String albumId) async {
    await _remoteSource.leaveAlbum(albumId);
    await DatabaseService.deleteAlbum(albumId);
  }

  // ========== Private ==========

  Future<void> _saveAlbumsToLocal(List<Album> albums) async {
    for (final album in albums) {
      await _saveAlbumToLocal(album);
    }
  }

  Future<void> _saveAlbumToLocal(Album album) async {
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
  }

  Future<List<Album>> _getAlbumsFromLocal() async {
    final locals = await DatabaseService.getAllAlbums();
    return locals.map(_localToEntity).toList();
  }

  Future<Album> _getAlbumFromLocal(String albumId) async {
    final local = await DatabaseService.getAlbum(albumId);
    if (local == null) throw Exception('앨범을 찾을 수 없습니다: $albumId');
    return _localToEntity(local);
  }

  Album _localToEntity(AlbumLocal local) {
    final categories = local.categoriesJson
        ?.split(',')
        .where((c) => c.isNotEmpty)
        .toList() ??
        [];
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