import '../comment_remote_source.dart';
import '../../../models/photo/photo_dto.dart';
import '../../../../../core/network/network_exception.dart';

class MockCommentRemoteSource implements CommentRemoteSource {
  // ✅ Mock 현재 사용자
  static const String _currentUserId = 'user-uuid-1';
  static const String _currentUserNickname = '석스키';

  // ✅ 사진별 댓글 저장
  final Map<String, List<CommentDto>> _commentsByPhoto = {
    'photo-uuid-1': [
      CommentDto(
        commentId: 'comment-uuid-1',
        photoId: 'photo-uuid-1',
        userId: 'user-uuid-2',
        nickname: '민지',
        profileImageUrl: null,
        content: '너무 예뻐!',
        createdAt: '2025-04-18T14:35:00Z',
      ),
    ],
    'photo-uuid-3': [
      CommentDto(
        commentId: 'comment-uuid-2',
        photoId: 'photo-uuid-3',
        userId: 'user-uuid-1',
        nickname: '석스키',
        profileImageUrl: null,
        content: '고마워 준혁아',
        createdAt: '2025-04-18T14:45:00Z',
      ),
    ],
  };

  int _nextId = 100;

  @override
  Future<List<CommentDto>> getComments(String photoId) async {  // ✅ String
    await Future.delayed(const Duration(milliseconds: 500));
    return _commentsByPhoto[photoId] ?? [];
  }

  @override
  Future<CommentDto> addComment(String photoId, String content) async {  // ✅ String
    await Future.delayed(const Duration(milliseconds: 800));

    final newComment = CommentDto(
      commentId: 'comment-uuid-$_nextId',
      photoId: photoId,
      userId: _currentUserId,
      nickname: _currentUserNickname,
      profileImageUrl: null,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
    );

    _commentsByPhoto.putIfAbsent(photoId, () => []);
    _commentsByPhoto[photoId]!.add(newComment);
    _nextId++;

    return newComment;
  }

  @override
  Future<void> deleteComment(String photoId, String commentId) async {  // ✅ String
    await Future.delayed(const Duration(milliseconds: 500));

    final comments = _commentsByPhoto[photoId];
    if (comments == null) {
      throw NetworkException(
        message: '댓글을 찾을 수 없습니다',
        type: NetworkExceptionType.notFound,
        statusCode: 404,
      );
    }

    comments.removeWhere((c) => c.commentId == commentId);
  }
}