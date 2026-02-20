import '../entities/photo.dart';

abstract class CommentRepository {
  Future<List<Comment>> getComments(int photoId);
  Future<Comment> addComment(int photoId, String text);
  Future<void> deleteComment(int photoId, int commentIndex);
}