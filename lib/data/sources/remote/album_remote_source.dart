import '../../models/album/album_dto.dart';
import '../../models/album/album_member_dto.dart';
import '../../models/album/create_album_request.dart';
import '../../models/album/join_album_request.dart';
import '../../models/album/update_album_request.dart';

abstract class AlbumRemoteSource {
  Future<List<AlbumDto>> getAlbums();
  Future<AlbumDto> getAlbum(String albumId);
  Future<AlbumDto> createAlbum(CreateAlbumRequest request);
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request);
  Future<AlbumDto> updateAlbum(String albumId, UpdateAlbumRequest request);
  Future<void> deleteAlbum(String albumId);
  Future<void> leaveAlbum(String albumId);
  Future<List<AlbumMemberDto>> getMembers(String albumId);
  Future<void> updateMemberRole(String albumId, String memberId, String role);
  Future<void> kickMember(String albumId, String memberId);
  Future<void> verifyInviteCode(String inviteCode);
}