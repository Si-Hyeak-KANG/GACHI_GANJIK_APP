import '../reaction_remote_source.dart';

class MockReactionRemoteSource implements ReactionRemoteSource {
  // photoId → isLiked 상태
  final Map<String, bool> _likeStatus = {};
  final Map<String, int> _likeCounts = {
    'photo-uuid-1': 5,
  };

  @override
  Future<ReactionResult> toggleLike(String albumId, String photoId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final current = _likeStatus[photoId] ?? false;
    final newStatus = !current;
    _likeStatus[photoId] = newStatus;

    final currentCount = _likeCounts[photoId] ?? 0;
    final newCount = newStatus ? currentCount + 1 : currentCount - 1;
    _likeCounts[photoId] = newCount.clamp(0, 999999);

    return ReactionResult(
      isLiked: newStatus,
      likeCount: _likeCounts[photoId]!,
    );
  }
}