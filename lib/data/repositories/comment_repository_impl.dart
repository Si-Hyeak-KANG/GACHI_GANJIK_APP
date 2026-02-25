import '../../domain/entities/photo.dart';
import '../../domain/repositories/comment_repository.dart';
import '../sources/remote/comment_remote_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteSource _remoteSource;

  CommentRepositoryImpl({required CommentRemoteSource remoteSource})
      : _remoteSource = remoteSource;

  @override
  Future<List<Comment>> getComments(String photoId) async {  // ✅ String
    final dtos = await _remoteSource.getComments(photoId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Comment> addComment(String photoId, String content) async {  // ✅ String, text → content
    final dto = await _remoteSource.addComment(photoId, content);
    return dto.toEntity();
  }

  @override
  Future<void> deleteComment(String photoId, String commentId) async {  // ✅ String (index → commentId)
    await _remoteSource.deleteComment(photoId, commentId);
  }
}