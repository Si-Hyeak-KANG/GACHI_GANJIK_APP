import '../../../../../core/network/dio_client.dart';
import '../../../../../core/storage/local_storage.dart';
import '../../../models/album/album_dto.dart';
import '../../../models/album/album_member_dto.dart';
import '../../../models/album/create_album_request.dart';
import '../../../models/album/join_album_request.dart';
import '../../../models/album/update_album_request.dart';
import '../album_remote_source.dart';

class RealAlbumRemoteSource implements AlbumRemoteSource {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  RealAlbumRemoteSource({
    required DioClient dioClient,
    required LocalStorage localStorage,
  })  : _dioClient = dioClient,
        _localStorage = localStorage;

  String? get _currentUserId => _localStorage.getUserId();

  @override
  Future<List<AlbumDto>> getAlbums() async {
    final response = await _dioClient.get('/albums');
    final data = response.data['data'] as Map<String, dynamic>;
    final list = data['albums'] as List<dynamic>;
    return list
        .map((e) => AlbumDto.fromJson(
      e as Map<String, dynamic>,
      currentUserId: _currentUserId,
    ))
        .toList();
  }

  @override
  Future<AlbumDto> getAlbum(String albumId) async {
    final response = await _dioClient.get('/albums/$albumId');
    return AlbumDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
      currentUserId: _currentUserId,
    );
  }

  @override
  Future<AlbumDto> createAlbum(CreateAlbumRequest request) async {
    final response = await _dioClient.post('/albums', data: request.toJson());
    final albumId = response.data['data']['albumId'] as String;
    return await getAlbum(albumId);
  }

  @override
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request) async {
    final response =
    await _dioClient.post('/albums/join', data: request.toJson());
    final albumId = response.data['data']['albumId'] as String;
    return await getAlbum(albumId);
  }

  @override
  Future<AlbumDto> updateAlbum(
      String albumId, UpdateAlbumRequest request) async {
    await _dioClient.patch('/albums/$albumId', data: request.toJson());
    return await getAlbum(albumId);
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    await _dioClient.delete('/albums/$albumId');
  }

  @override
  Future<void> leaveAlbum(String albumId) async {
    await _dioClient.delete('/albums/$albumId/members/me');
  }

  @override
  Future<List<AlbumMemberDto>> getMembers(String albumId) async {
    final response = await _dioClient.get('/albums/$albumId/members');
    final members = response.data['data']['members'] as List<dynamic>;
    return members
        .map((e) => AlbumMemberDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /albums/{albumId}/members/{memberId}/role
  /// role: "ADMIN" | "MEMBER"
  @override
  Future<void> updateMemberRole(
      String albumId, String memberId, String role) async {
    await _dioClient.patch(
      '/albums/$albumId/members/$memberId/role',
      data: {'role': role},
    );
  }

  /// DELETE /albums/{albumId}/members/{memberId}
  @override
  Future<void> kickMember(String albumId, String memberId) async {
    await _dioClient.delete('/albums/$albumId/members/$memberId');
  }

  /// GET /albums/verify
  @override
  Future<void> verifyInviteCode(String inviteCode) async {
    await _dioClient.get(
      '/albums/verify',
      queryParameters: {'inviteCode': inviteCode},
    );
  }
}