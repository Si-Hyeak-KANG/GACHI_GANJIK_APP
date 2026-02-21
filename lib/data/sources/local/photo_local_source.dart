import 'dart:convert';
import '../../../core/storage/database/database_service.dart';
import '../../../core/storage/database/photo_local.dart';
import '../../models/photo/photo_dto.dart';

class PhotoLocalSource {
  // 앨범의 로컬 사진 조회
  Future<List<PhotoDto>> getLocalPhotos(int albumId) async {
    final locals = await DatabaseService.getPhotosByAlbum(albumId);
    return locals.map(_toDto).toList();
  }

  // 사진 로컬 저장
  Future<void> savePhoto(PhotoDto dto) async {
    final local = PhotoLocal()
      ..albumId = dto.albumId
      ..imageUrl = dto.imageUrl
      ..message = dto.message
      ..uploader = dto.uploader
      ..uploadedAt = DateTime.parse(dto.uploadedAt.replaceAll('.', '-'))
      ..likeCount = dto.likeCount
      ..commentsJson = jsonEncode(dto.comments.map((c) => {'user': c.user, 'text': c.text}).toList())
      ..status = 'synced';

    await DatabaseService.savePhoto(local);
  }

  // PhotoLocal 직접 저장 (대기열용)
  Future<void> savePhotoLocal(PhotoLocal photo) async {
  await DatabaseService.savePhoto(photo);
  }

  // 대기 중인 사진 조회
  Future<List<PhotoLocal>> getPendingPhotos() async {
  return await DatabaseService.getPendingPhotos();
  }

  // DTO 변환
  PhotoDto _toDto(PhotoLocal local) {
    List<CommentDto> comments = [];
    if (local.commentsJson != null) {
      final list = jsonDecode(local.commentsJson!) as List;
      comments = list.map((c) => CommentDto.fromJson(c as Map<String, dynamic>)).toList();
    }

    return PhotoDto(
      id: local.id,
      albumId: local.albumId,
      imageUrl: local.imageUrl,
      message: local.message,
      uploader: local.uploader,
      uploadedAt: _formatDate(local.uploadedAt),
      likeCount: local.likeCount,
      comments: comments,
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}