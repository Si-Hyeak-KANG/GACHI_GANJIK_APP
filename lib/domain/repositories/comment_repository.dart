import '../entities/photo.dart';

abstract class CommentRepository {
  /// 댓글 목록 조회
  Future<List<Comment>> getComments(String photoId);

  /// 댓글 작성
  Future<Comment> addComment(String photoId, String content);

  /// 댓글 삭제
  Future<void> deleteComment(String photoId, String commentId);
}