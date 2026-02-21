import 'dart:io';
import 'package:get/get.dart';
import '../../core/storage/database/database_service.dart';
import '../../core/storage/database/photo_local.dart';
import '../../domain/entities/moment.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../presentation/controllers/network/network_controller.dart';
import '../models/photo/upload_photo_request.dart';
import '../sources/firebase/firebase_storage_source.dart';
import '../sources/local/photo_local_source.dart';
import '../sources/remote/photo_remote_source.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteSource _remoteSource;
  final PhotoLocalSource _localSource;
  final FirebaseStorageSource _storageSource;

  PhotoRepositoryImpl({
    required PhotoRemoteSource remoteSource,
    required PhotoLocalSource localSource,
    required FirebaseStorageSource storageSource,
  })  : _remoteSource = remoteSource,
        _localSource = localSource,
        _storageSource = storageSource;

  @override
  Future<List<Moment>> getAlbumMoments(int albumId) async {
    try {
      final dtos = await _remoteSource.getAlbumPhotos(albumId);

      for (final dto in dtos) {
        await _localSource.savePhoto(dto);
      }
      final photos = dtos.map((dto) => dto.toEntity()).toList();
      return _groupPhotosByDate(photos);
    } catch (e) {
      // 네트워크 오류 시 로컬 DB에서 조회
      print('서버 조회 실패, 로컬 DB 사용: $e');

      // ✅ localSource 사용
      final dtos = await _localSource.getLocalPhotos(albumId);
      final photos = dtos.map((dto) => dto.toEntity()).toList();
      return _groupPhotosByDate(photos);
    }
  }

  @override
  Future<Photo> uploadPhoto({
    required int albumId,
    required File imageFile,
    String? message,
  }) async {
    try {
      // 네트워크 상태 확인
      final networkController = Get.find<NetworkController>();

      if (!networkController.isConnected.value) {
        // 오프라인: 대기열에 추가
        return await _addToUploadQueue(albumId, imageFile, message);
      }

      // 온라인: 즉시 업로드
      // 1. Firebase Storage 업로드
      final imageUrl = await _storageSource.uploadImage(imageFile, albumId);

      // 2. 서버에 메타데이터 저장
      final request = UploadPhotoRequest(
        albumId: albumId,
        imageUrl: imageUrl,
        message: message,
      );
      final dto = await _remoteSource.uploadPhoto(request);
      await _localSource.savePhoto(dto);
      return dto.toEntity();
    } catch (e) {
      // 업로드 실패 시 대기열에 추가
      print('업로드 실패, 대기열 추가: $e');
      return await _addToUploadQueue(albumId, imageFile, message);
    }
  }

  // Photo → Moment 변환
  List<Moment> _groupPhotosByDate(List<Photo> photos) {
    final grouped = <String, List<Photo>>{};

    for (final photo in photos) {
      // "2025.04.18 10:30" → "2025.04.18"
      final date = photo.uploadedAt.split('T')[0];
      grouped.putIfAbsent(date, () => []).add(photo);
    }

    return grouped.entries.map((entry) {
      return Moment(
        date: entry.key,
        photos: entry.value,
        contributors: entry.value.map((p) => p.uploader).toSet().toList(),
      );
    }).toList();
  }

  // 업로드 대기열 추가
  Future<Photo> _addToUploadQueue(
      int albumId,
      File imageFile,
      String? message,
      ) async {
    // 임시 Photo 객체 생성
    final tempPhoto = PhotoLocal()
      ..albumId = albumId
      ..imageUrl = imageFile.path // 임시로 로컬 경로 저장
      ..message = message
      ..uploader = 'Me' // 현재 사용자
      ..uploadedAt = DateTime.now()
      ..status = 'pending' // 대기 중
      ..localPath = imageFile.path
      ..retryCount = 0;

    await _localSource.savePhotoLocal(tempPhoto);

    Get.snackbar(
      '오프라인',
      '온라인 연결 시 자동으로 업로드됩니다',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    return Photo(
      id: 0,
      albumId: albumId,
      imageUrl: imageFile.path,
      message: message,
      uploader: 'Me',
      uploadedAt: DateTime.now().toIso8601String(),
      likeCount: 0,
      comments: [],
    );
  }
}