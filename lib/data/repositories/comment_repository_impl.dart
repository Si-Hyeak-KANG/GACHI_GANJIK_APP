import '../../domain/entities/photo.dart';
import '../../domain/repositories/comment_repository.dart';
import '../sources/remote/comment_remote_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteSource _remoteSource;

  CommentRepositoryImpl({required CommentRemoteSource remoteSource})
      : _remoteSource = remoteSource;

  @override
  Future<List<Comment>> getComments(int photoId) async {
    final dtos = await _remoteSource.getComments(photoId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Comment> addComment(int photoId, String text) async {
    final dto = await _remoteSource.addComment(photoId, text);
    return dto.toEntity();
  }

  @override
  Future<void> deleteComment(int photoId, int commentIndex) async {
    await _remoteSource.deleteComment(photoId, commentIndex);
  }
}