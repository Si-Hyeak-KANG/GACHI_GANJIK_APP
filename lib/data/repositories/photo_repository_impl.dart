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
      return Get.find<AuthController>().currentUser.value?.userId ?? 'user-uuid-1';
    } catch (_) {
      return 'user-uuid-1';
    }
  }

  String get _currentUserNickname {
    try {
      return Get.find<AuthController>().currentUser.value?.nickname ?? '석스키';
    } catch (_) {
      return '석스키';
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

    // Mock 환경에서는 Firebase 업로드 없이 로컬 경로 사용
    const useRealApi = bool.fromEnvironment('USE_REAL_API', defaultValue: false);

    final String imageUrl;
    if (useRealApi) {
      imageUrl = await _storageSource.uploadImage(imageFile, albumId);
    } else {
      imageUrl = imageFile.path;
    }

    final request = UploadPhotoRequest(
      albumId: albumId,
      imageUrl: imageUrl,
      message: message,
      photoDate: photoDate,
    );

    final dto = await _remoteSource.uploadPhoto(request);
    await _localSource.savePhoto(dto);
    return dto.toEntity();
  }

  @override
  Future<void> deletePhoto(String photoId, {required String albumId}) async {
    await _remoteSource.deletePhoto(albumId, photoId);
    await DatabaseService.deletePhoto(photoId);
  }

  Future<ReactionResult> toggleLike(String albumId, String photoId) async {
    return await _reactionRemoteSource.toggleLike(albumId, photoId);
  }

  // ========== Private ==========

  List<Moment> _groupPhotosByDate(List<Photo> photos) {
    final grouped = <String, List<Photo>>{};
    for (final photo in photos) {
      grouped.putIfAbsent(photo.photoDate, () => []).add(photo);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((date) {
      final datePhotos = grouped[date]!;
      return Moment(
        date: date,
        photos: datePhotos,
        contributors: datePhotos.map((p) => p.uploaderNickname).toSet().toList(),
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