import '../entities/album.dart';

abstract class AlbumRepository {
  /// 앨범 목록 조회 (온라인 우선)
  Future<List<Album>> getAlbums();

  /// 앨범 생성
  Future<Album> createAlbum({
    required String title,
    required List<String> categories,
    required String eventStartDate,     // ✅ YYYY-MM-DD
    String? eventEndDate,                // ✅ YYYY-MM-DD
  });

  /// 앨범 참여 (초대 코드)
  Future<Album> joinAlbum(String inviteCode);

  /// 앨범 상세 조회 (온라인 우선)
  Future<Album> getAlbum(String albumId);  // ✅ 추가

  /// 앨범 수정 (관리자만)
  Future<Album> updateAlbum({
    required String albumId,
    required String title,
    required List<String> categories,
    required String eventStartDate,
    String? eventEndDate,
  });  // ✅ 추가

  /// 앨범 삭제 (소유자만)
  Future<void> deleteAlbum(String albumId);  // ✅ 추가

  /// 앨범 나가기 (참여자)
  Future<void> leaveAlbum(String albumId);  // ✅ 추가
}