import 'package:isar_community/isar.dart';

part 'album_local.g.dart';

// → 오프라인에서 앨범 목록 표시
// → 네트워크 없이도 앱 사용 가능
@collection
class AlbumLocal {
  Id id = Isar.autoIncrement;

  @Index()
  late int albumId; // 서버의 실제 앨범 ID

  late String title;
  String? category;
  String? eventDate;
  String? coverImage;
  late String inviteCode;

  int photoCount = 0;
  int memberCount = 0;

  late DateTime createdAt;
  late DateTime lastSyncedAt; // 마지막 동기화 시간

  // 동기화 상태
  @Index()
  String syncStatus = 'synced'; // synced, pending, failed
}