import 'package:isar_community/isar.dart';

part 'like_local.g.dart';

// 좋아요는 사진과 독립적으로 관리 (N:M 관계)
// 오프라인에서도 좋아요 상태 유지
@collection
class LikeLocal {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('userId')], unique: true)
  late int photoId;

  late String userId; // 현재 사용자 ID

  late DateTime likedAt;
}