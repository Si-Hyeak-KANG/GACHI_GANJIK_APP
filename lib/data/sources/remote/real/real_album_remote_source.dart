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
    // 생성 응답: albumId, title, inviteCode, role만 반환 → GET으로 전체 조회
    final albumId = response.data['data']['albumId'] as String;
    return await getAlbum(albumId);
  }

  @override
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request) async {
    final response = await _dioClient.post('/albums/join', data: request.toJson());
    // 참여 응답: albumId, title, role만 반환 → GET으로 전체 조회
    final albumId = response.data['data']['albumId'] as String;
    return await getAlbum(albumId);
  }

  @override
  Future<AlbumDto> updateAlbum(String albumId, UpdateAlbumRequest request) async {
    await _dioClient.patch('/albums/$albumId', data: request.toJson());
    // 수정 응답이 요약만 반환 → GET으로 전체 재조회
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
}