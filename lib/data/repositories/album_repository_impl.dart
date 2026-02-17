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
    final dtos = await _remoteSource.getAlbums();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Album> createAlbum({
    required String title,
    String? category,
    String? eventDate,
  }) async {
    final dto = await _remoteSource.createAlbum(
      CreateAlbumRequest(
        title: title,
        category: category,
        eventDate: eventDate,
      ),
    );
    return dto.toEntity();
  }

  @override
  Future<Album> joinAlbum(String inviteCode) async {
    final dto = await _remoteSource.joinAlbum(
      JoinAlbumRequest(inviteCode: inviteCode),
    );
    return dto.toEntity();
  }
}