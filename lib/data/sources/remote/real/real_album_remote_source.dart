import '../../../../../core/network/dio_client.dart';
import '../../../models/album/album_dto.dart';
import '../../../models/album/create_album_request.dart';
import '../../../models/album/join_album_request.dart';
import '../../../models/album/update_album_request.dart';
import '../album_remote_source.dart';

class RealAlbumRemoteSource implements AlbumRemoteSource {
  final DioClient _dioClient;

  RealAlbumRemoteSource({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<AlbumDto>> getAlbums() async {
    final response = await _dioClient.get('/albums');
    final data = response.data['data'] as Map<String, dynamic>;
    final list = data['albums'] as List<dynamic>;
    return list
        .map((e) => AlbumDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AlbumDto> getAlbum(String albumId) async {
    final response = await _dioClient.get('/albums/$albumId');
    return AlbumDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AlbumDto> createAlbum(CreateAlbumRequest request) async {
    final response = await _dioClient.post('/albums', data: request.toJson());
    return AlbumDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AlbumDto> joinAlbum(JoinAlbumRequest request) async {
    final response = await _dioClient.post(
      '/albums/join',
      data: request.toJson(),
    );
    return AlbumDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AlbumDto> updateAlbum(
      String albumId,
      UpdateAlbumRequest request,
      ) async {
    final response = await _dioClient.patch(
      '/albums/$albumId',
      data: request.toJson(),
    );
    return AlbumDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    await _dioClient.delete('/albums/$albumId');
  }

  @override
  Future<void> leaveAlbum(String albumId) async {
    await _dioClient.delete('/albums/$albumId/members/me');
  }
}