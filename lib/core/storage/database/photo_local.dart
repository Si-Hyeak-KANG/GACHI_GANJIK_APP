import 'package:isar_community/isar.dart';

part 'photo_local.g.dart';

@collection
class PhotoLocal {
  Id id = Isar.autoIncrement;

  @Index()
  late String photoId;

  @Index()
  late String albumId;

  late String imageUrl;
  String? thumbnailUrl;
  String? message;
  late String photoDate;

  late String uploaderId;
  late String uploaderNickname;
  String? uploaderProfileImageUrl;

  late DateTime createdAt;
  int likeCount = 0;
  int commentCount = 0;

  @Index()
  String status = 'synced';         // synced, pending, failed

  String? localPath;                // 업로드 대기 중인 로컬 파일
  int retryCount = 0;
  DateTime? lastSyncAttempt;
}