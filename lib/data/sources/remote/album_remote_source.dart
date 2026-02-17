import '../../models/album/album_dto.dart';
import '../../models/album/create_album_request.dart';
import '../../models/album/join_album_request.dart';

abstract class AlbumRemoteSource {
  Future<List<AlbumDto>> getAlbums();
  Future<AlbumDto> createAlbum(CreateAlbumRequest request);
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request);
}