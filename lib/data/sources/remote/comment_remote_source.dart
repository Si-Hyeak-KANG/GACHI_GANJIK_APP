import '../../models/photo/photo_dto.dart';

abstract class CommentRemoteSource {
  /// 댓글 목록 조회
  Future<List<CommentDto>> getComments(String photoId);  // ✅ String

  /// 댓글 작성
  Future<CommentDto> addComment(String photoId, String content);  // ✅ String

  /// 댓글 삭제
  Future<void> deleteComment(String photoId, String commentId);  // ✅ String
}