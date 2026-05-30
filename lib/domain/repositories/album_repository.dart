import '../entities/album_member.dart';
import '../entities/album.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAlbums();

  Future<Album> createAlbum({
    required String title,
    required List<String> categories,
    required String eventStartDate,
    String? eventEndDate,
    String? coverImageUrl,
  });

  Future<Album> joinAlbum(String inviteCode);

  Future<Album> getAlbum(String albumId);

  Future<Album> updateAlbum({
    required String albumId,
    required String title,
    required List<String> categories,
    required String eventStartDate,
    String? eventEndDate,
    String? coverImageUrl,
  });

  Future<void> deleteAlbum(String albumId);

  Future<void> leaveAlbum(String albumId);

  Future<List<AlbumMember>> getMembers(String albumId);
  Future<void> updateMemberRole(String albumId, String memberId, String role);
  Future<void> kickMember(String albumId, String memberId);
}