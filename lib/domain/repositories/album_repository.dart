import '../entities/album.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAlbums();

  Future<Album> createAlbum({
    required String title,
    required List<String> categories,
    required String eventStartDate,
    String? eventEndDate,
  });

  Future<Album> joinAlbum(String inviteCode);
}