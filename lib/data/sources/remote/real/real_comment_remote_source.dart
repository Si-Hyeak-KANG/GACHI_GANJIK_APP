import '../../../../../core/network/dio_client.dart';
import '../../../models/photo/photo_dto.dart';
import '../comment_remote_source.dart';

class RealCommentRemoteSource implements CommentRemoteSource {
  final DioClient _dioClient;

  RealCommentRemoteSource({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<CommentDto>> getComments(String photoId) async {
    final parts = _splitPhotoId(photoId);
    final response = await _dioClient.get(
      '/albums/${parts.$1}/photos/${parts.$2}/comments',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final list = data['comments'] as List<dynamic>;
    return list
        .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CommentDto> addComment(String photoId, String content) async {
    final parts = _splitPhotoId(photoId);
    final response = await _dioClient.post(
      '/albums/${parts.$1}/photos/${parts.$2}/comments',
      data: {'content': content},
    );
    return CommentDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteComment(String photoId, String commentId) async {
    final parts = _splitPhotoId(photoId);
    await _dioClient.delete(
      '/albums/${parts.$1}/photos/${parts.$2}/comments/$commentId',
    );
  }

  /// "albumId::photoId" → (albumId, photoId)
  (String, String) _splitPhotoId(String photoId) {
    final parts = photoId.split('::');
    if (parts.length == 2) return (parts[0], parts[1]);
    return ('', photoId);
  }
}