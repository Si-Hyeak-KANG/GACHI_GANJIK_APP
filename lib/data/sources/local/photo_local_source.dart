import '../../../core/storage/database/database_service.dart';
import '../../../core/storage/database/photo_local.dart';
import '../../models/photo/photo_dto.dart';
import 'dart:convert';

class PhotoLocalSource {
  /// 앨범의 로컬 사진 조회
  Future<List<PhotoDto>> getLocalPhotos(String albumId) async {  // ✅ String
    final locals = await DatabaseService.getPhotosByAlbum(albumId);
    return locals.map(_localToDto).toList();
  }

  /// 사진 저장
  Future<void> savePhoto(PhotoDto dto) async {
    final local = _dtoToLocal(dto);
    await DatabaseService.savePhoto(local);
  }

  /// PhotoLocal 저장
  Future<void> savePhotoLocal(PhotoLocal local) async {
    await DatabaseService.savePhoto(local);
  }

  /// DTO → PhotoLocal 변환
  PhotoLocal _dtoToLocal(PhotoDto dto) {
    return PhotoLocal()
      ..photoId = dto.id
      ..albumId = dto.albumId
      ..imageUrl = dto.imageUrl
      ..thumbnailUrl = dto.thumbnailUrl
      ..message = dto.message
      ..photoDate = dto.photoDate
      ..uploaderId = dto.uploaderId
      ..uploaderNickname = dto.uploaderNickname
      ..uploaderProfileImageUrl = dto.uploaderProfileImageUrl
      ..createdAt = DateTime.parse(dto.createdAt)
      ..likeCount = dto.likeCount
      ..commentCount = dto.commentCount
      ..status = 'synced';
  }

  /// PhotoLocal → DTO 변환
  PhotoDto _localToDto(PhotoLocal local) {
    return PhotoDto(
      id: local.photoId,
      albumId: local.albumId,
      imageUrl: local.imageUrl,
      thumbnailUrl: local.thumbnailUrl,
      message: local.message,
      photoDate: local.photoDate,
      uploaderId: local.uploaderId,
      uploaderNickname: local.uploaderNickname,
      uploaderProfileImageUrl: local.uploaderProfileImageUrl,
      createdAt: local.createdAt.toIso8601String(),
      likeCount: local.likeCount,
      commentCount: local.commentCount,
    );
  }
}