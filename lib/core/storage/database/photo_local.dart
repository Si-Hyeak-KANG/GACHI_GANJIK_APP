import 'package:isar_community/isar.dart';

part 'photo_local.g.dart';

@collection
class PhotoLocal {
  Id id = Isar.autoIncrement;

  @Index()
  late int albumId;

  late String imageUrl;
  String? message;
  late String uploader;
  late DateTime uploadedAt;

  int likeCount = 0;
  String? commentsJson;

  // 동기화 상태 추가
  @Index()
  String status = 'synced'; // synced, pending, failed

  // 로컬 파일 경로 (업로드 대기 중)
  String? localPath;

  // 재시도 횟수
  int retryCount = 0;

  // 마지막 동기화 시도 시간
  DateTime? lastSyncAttempt;
}