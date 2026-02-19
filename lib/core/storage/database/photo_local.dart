import 'package:isar_community/isar.dart';

part 'photo_local.g.dart'; // build_runner가 생성

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

  // JSON으로 저장
  String? commentsJson;

  // 업로드 상태 (pending, uploaded, failed)
  @Index()
  String status = 'uploaded';

  // 로컬 파일 경로 (업로드 대기 중일 때)
  String? localPath;
}