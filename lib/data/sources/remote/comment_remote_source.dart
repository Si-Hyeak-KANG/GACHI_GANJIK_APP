import '../../models/photo/photo_dto.dart';

abstract class CommentRemoteSource {
  Future<List<CommentDto>> getComments(int photoId);
  Future<CommentDto> addComment(int photoId, String text);
  Future<void> deleteComment(int photoId, int commentIndex);
}