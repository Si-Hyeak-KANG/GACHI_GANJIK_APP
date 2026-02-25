import '../../../core/storage/database/database_service.dart';

class LikeLocalSource {
  /// 좋아요 상태 확인
  Future<bool> isLiked(String photoId, String userId) async {  // ✅ String
    return await DatabaseService.isLiked(photoId, userId);
  }

  /// 좋아요 토글
  Future<void> toggleLike(String photoId, String userId) async {  // ✅ String
    final isLiked = await DatabaseService.isLiked(photoId, userId);

    if (isLiked) {
      await DatabaseService.removeLike(photoId, userId);
    } else {
      await DatabaseService.addLike(photoId, userId);
    }
  }

  /// 좋아요 수 조회
  Future<int> getLikeCount(String photoId) async {  // ✅ String
    return await DatabaseService.getLikeCount(photoId);
  }
}