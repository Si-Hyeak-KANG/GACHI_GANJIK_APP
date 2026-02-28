import '../../../../../core/network/dio_client.dart';
import '../reaction_remote_source.dart';

class RealReactionRemoteSource implements ReactionRemoteSource {
  final DioClient _dioClient;

  RealReactionRemoteSource({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<ReactionResult> toggleLike(String albumId, String photoId) async {
    final response = await _dioClient.post(
      '/albums/$albumId/photos/$photoId/reactions',
      data: {'reactionType': 'LIKE'},
    );
    return ReactionResult.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}