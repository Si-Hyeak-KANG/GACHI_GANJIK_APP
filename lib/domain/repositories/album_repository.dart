import '../entities/album.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAlbums();
  Future<Album> createAlbum({
    required String title,
    String? category,
    String? eventDate,
  });
  Future<Album> joinAlbum(String inviteCode);
}