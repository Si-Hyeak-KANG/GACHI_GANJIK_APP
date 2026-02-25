import '../../models/album/album_dto.dart';
import '../../models/album/create_album_request.dart';
import '../../models/album/join_album_request.dart';

abstract class AlbumRemoteSource {
  /// 앨범 목록 조회
  Future<List<AlbumDto>> getAlbums();

  /// 앨범 생성
  Future<AlbumDto> createAlbum(CreateAlbumRequest request);

  /// 앨범 참여 (초대 코드)
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request);
}