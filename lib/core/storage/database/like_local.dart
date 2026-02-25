import 'package:isar_community/isar.dart';

part 'like_local.g.dart';

@collection
class LikeLocal {
  Id id = Isar.autoIncrement;

  @Index()
  late String photoId;    // ✅ int → String

  @Index()
  late String userId;     // ✅ String 유지

  late DateTime likedAt;
}