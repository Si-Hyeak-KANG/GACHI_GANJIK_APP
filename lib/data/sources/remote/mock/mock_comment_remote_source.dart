import '../comment_remote_source.dart';
import '../../../models/photo/photo_dto.dart';

class MockCommentRemoteSource implements CommentRemoteSource {
  // 댓글 저장소 (photoId → 댓글 리스트)
  final Map<int, List<CommentDto>> _comments = {};

  @override
  Future<List<CommentDto>> getComments(int photoId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_comments[photoId] ?? []);
  }

  @override
  Future<CommentDto> addComment(int photoId, String text) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final comment = CommentDto(
      user: '나', // Phase 5에서 실제 사용자 이름으로
      text: text,
    );

    _comments.putIfAbsent(photoId, () => []);
    _comments[photoId]!.add(comment);

    return comment;
  }

  @override
  Future<void> deleteComment(int photoId, int commentIndex) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_comments.containsKey(photoId)) {
      if (commentIndex >= 0 && commentIndex < _comments[photoId]!.length) {
        _comments[photoId]!.removeAt(commentIndex);
      }
    }
  }
}