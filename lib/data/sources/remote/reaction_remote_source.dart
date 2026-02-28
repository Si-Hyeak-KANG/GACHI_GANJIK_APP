// API 명세서 8.2 반응(좋아요) 토글
class ReactionResult {
  final bool isLiked;
  final int likeCount;

  ReactionResult({required this.isLiked, required this.likeCount});

  factory ReactionResult.fromJson(Map<String, dynamic> json) {
    return ReactionResult(
      isLiked: json['isLiked'] as bool,
      likeCount: json['likeCount'] as int,
    );
  }
}

abstract class ReactionRemoteSource {
  /// 좋아요 토글 (8.2)
  Future<ReactionResult> toggleLike(String albumId, String photoId);
}