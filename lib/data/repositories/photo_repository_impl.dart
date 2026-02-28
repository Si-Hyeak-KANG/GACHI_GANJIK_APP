import 'dart:io';
import 'package:get/get.dart';
import '../../core/storage/database/database_service.dart';
import '../../core/storage/database/photo_local.dart';
import '../../domain/entities/moment.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../presentation/controllers/auth/auth_controller.dart';
import '../../presentation/controllers/network/network_controller.dart';
import '../models/photo/upload_photo_request.dart';
import '../sources/firebase/firebase_storage_source.dart';
import '../sources/local/photo_local_source.dart';
import '../sources/remote/photo_remote_source.dart';
import '../sources/remote/reaction_remote_source.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteSource _remoteSource;
  final ReactionRemoteSource _reactionRemoteSource;
  final PhotoLocalSource _localSource;
  final FirebaseStorageSource _storageSource;

  PhotoRepositoryImpl({
    required PhotoRemoteSource remoteSource,
    required ReactionRemoteSource reactionRemoteSource,
    required PhotoLocalSource localSource,
    required FirebaseStorageSource storageSource,
  })  : _remoteSource = remoteSource,
        _reactionRemoteSource = reactionRemoteSource,
        _localSource = localSource,
        _storageSource = storageSource;

  String get _currentUserId {
    try {
      return Get.find<AuthController>().currentUser.value?.userId ?? '';
    } catch (_) {
      return '';
    }
  }

  String get _currentUserNickname {
    try {
      return Get.find<AuthController>().currentUser.value?.nickname ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<List<Moment>> getAlbumMoments(String albumId) async {
    try {
      final dtos = await _remoteSource.getAlbumPhotos(albumId);
      for (final dto in dtos) {
        await _localSource.savePhoto(dto);
      }
      final photos = dtos.map((dto) => dto.toEntity()).toList();
      return _groupPhotosByDate(photos);
    } catch (e) {
      final dtos = await _localSource.getLocalPhotos(albumId);
      final photos = dtos.map((dto) => dto.toEntity()).toList();
      return _groupPhotosByDate(photos);
    }
  }

  @override
  Future<Photo> uploadPhoto({
    required String albumId,
    required File imageFile,
    String? message,
    required String photoDate,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isConnected.value) {
      return await _addToUploadQueue(albumId, imageFile, message, photoDate);
    }

    try {
      // 1. Firebase Storage에 이미지 업로드 → URL 획득
      final imageUrl = await _storageSource.uploadImage(imageFile, albumId);

      // 2. 서버에 URL + 메타데이터 저장
      final request = UploadPhotoRequest(
        albumId: albumId,
        imageUrl: imageUrl,
        message: message,
        photoDate: photoDate,
      );

      final dto = await _remoteSource.uploadPhoto(request);
      await _localSource.savePhoto(dto);
      return dto.toEntity();
    } catch (e) {
      return await _addToUploadQueue(albumId, imageFile, message, photoDate);
    }
  }

  @override
  Future<void> deletePhoto(String photoId, {required String albumId}) async {
    await _remoteSource.deletePhoto(albumId, photoId);
    await DatabaseService.deletePhoto(photoId);
  }

  /// 좋아요 토글 (서버 연동) → (isLiked, likeCount) 반환
  Future<({bool isLiked, int likeCount})> toggleLike(
      String albumId,
      String photoId,
      ) async {
    final result = await _reactionRemoteSource.toggleLike(albumId, photoId);
    return (isLiked: result.isLiked, likeCount: result.likeCount);
  }

  // ========== Private ==========

  List<Moment> _groupPhotosByDate(List<Photo> photos) {
    final grouped = <String, List<Photo>>{};
    for (final photo in photos) {
      grouped.putIfAbsent(photo.photoDate, () => []).add(photo);
    }
    // 날짜 내림차순 정렬
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys.map((date) {
      final datePhotos = grouped[date]!;
      return Moment(
        date: date,
        photos: datePhotos,
        contributors: datePhotos
            .map((p) => p.uploaderNickname)
            .toSet()
            .toList(),
      );
    }).toList();
  }

  Future<Photo> _addToUploadQueue(
      String albumId,
      File imageFile,
      String? message,
      String photoDate,
      ) async {
    final now = DateTime.now();
    final tempId = 'temp-${now.millisecondsSinceEpoch}';

    final tempPhoto = PhotoLocal()
      ..photoId = tempId
      ..albumId = albumId
      ..imageUrl = imageFile.path
      ..thumbnailUrl = imageFile.path
      ..message = message
      ..photoDate = photoDate
      ..uploaderId = _currentUserId
      ..uploaderNickname = _currentUserNickname
      ..uploaderProfileImageUrl = null
      ..createdAt = now
      ..likeCount = 0
      ..commentCount = 0
      ..status = 'pending'
      ..localPath = imageFile.path
      ..retryCount = 0
      ..lastSyncAttempt = null;

    await _localSource.savePhotoLocal(tempPhoto);

    Get.snackbar(
      '오프라인',
      '온라인 연결 시 자동으로 업로드됩니다',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    return Photo(
      id: tempId,
      albumId: albumId,
      imageUrl: imageFile.path,
      thumbnailUrl: imageFile.path,
      message: message,
      photoDate: photoDate,
      uploaderId: _currentUserId,
      uploaderNickname: _currentUserNickname,
      uploaderProfileImageUrl: null,
      createdAt: now,
      likeCount: 0,
      commentCount: 0,
    );
  }
}