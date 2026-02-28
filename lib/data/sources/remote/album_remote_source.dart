import '../../models/album/album_dto.dart';
import '../../models/album/create_album_request.dart';
import '../../models/album/join_album_request.dart';
import '../../models/album/update_album_request.dart';

abstract class AlbumRemoteSource {
  /// 앨범 목록 조회 (5.2)
  Future<List<AlbumDto>> getAlbums();

  /// 앨범 단건 조회 (5.3)
  Future<AlbumDto> getAlbum(String albumId);

  /// 앨범 생성 (5.4)
  Future<AlbumDto> createAlbum(CreateAlbumRequest request);

  /// 앨범 참여 - 초대 코드 (5.5)
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request);

  /// 앨범 수정 (5.6) - OWNER/ADMIN만
  Future<AlbumDto> updateAlbum(String albumId, UpdateAlbumRequest request);

  /// 앨범 삭제 (5.7) - OWNER만
  Future<void> deleteAlbum(String albumId);

  /// 앨범 나가기 (5.8) - MEMBER/ADMIN
  Future<void> leaveAlbum(String albumId);
}