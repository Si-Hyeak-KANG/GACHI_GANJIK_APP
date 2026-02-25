import 'dart:io';
import 'package:get/get.dart';
import '../../core/storage/database/database_service.dart';
import '../../core/storage/database/photo_local.dart';
import '../../domain/entities/moment.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../presentation/controllers/network/network_controller.dart';
import '../models/photo/moment_dto.dart';  // ✅ 추가
import '../models/photo/upload_photo_request.dart';
import '../sources/firebase/firebase_storage_source.dart';
import '../sources/local/photo_local_source.dart';
import '../sources/remote/photo_remote_source.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteSource _remoteSource;
  final PhotoLocalSource _localSource;
  final FirebaseStorageSource _storageSource;

  // ✅ 현재 사용자 정보
  String get _currentUserId => 'user-uuid-1';
  String get _currentUserNickname => '석스키';

  PhotoRepositoryImpl({
    required PhotoRemoteSource remoteSource,
    required PhotoLocalSource localSource,
    required FirebaseStorageSource storageSource,
  })  : _remoteSource = remoteSource,
        _localSource = localSource,
        _storageSource = storageSource;

  // ✅ 온라인 우선: 서버 → 로컬 저장 → 실패 시 로컬 조회
  @override
  Future<List<Moment>> getAlbumMoments(String albumId) async {  // ✅ String
    try {
      print('🔵 서버에서 사진 목록 조회: $albumId');

      // 1. 서버에서 조회 (이미 그룹화된 Moments 반환)
      final dtos = await _remoteSource.getAlbumPhotos(albumId);
      print('🔵 서버 조회 성공: ${dtos.length}개 사진');

      // 2. 로컬 DB에 저장
      for (final dto in dtos) {
        await _localSource.savePhoto(dto);
      }
      print('🔵 로컬 DB 캐싱 완료');

      // 3. 엔티티 변환 및 그룹화
      final photos = dtos.map((dto) => dto.toEntity()).toList();
      return _groupPhotosByDate(photos);

    } catch (e) {
      print('⚠️ 서버 조회 실패, 로컬 DB 사용: $e');

      // 4. 폴백: 로컬 DB에서 조회
      final dtos = await _localSource.getLocalPhotos(albumId);
      final photos = dtos.map((dto) => dto.toEntity()).toList();
      return _groupPhotosByDate(photos);
    }
  }

  @override
  Future<Photo> uploadPhoto({
    required String albumId,           // ✅ String
    required File imageFile,
    String? message,
    required String photoDate,         // ✅ 추가
  }) async {
    try {
      print('🔵 사진 업로드 시작: $albumId');

      // 네트워크 상태 확인
      final networkController = Get.find<NetworkController>();

      if (!networkController.isConnected.value) {
        print('⚠️ 오프라인 상태, 대기열에 추가');
        return await _addToUploadQueue(albumId, imageFile, message, photoDate);
      }

      // 온라인: 즉시 업로드
      print('🔵 Firebase Storage 업로드 시작');

      // 1. Firebase Storage 업로드
      final imageUrl = await _storageSource.uploadImage(imageFile, albumId);
      print('🔵 Firebase 업로드 완료: $imageUrl');

      // 2. 서버에 메타데이터 저장
      final request = UploadPhotoRequest(
        albumId: albumId,
        imageUrl: imageUrl,
        message: message,
        photoDate: photoDate,
      );

      final dto = await _remoteSource.uploadPhoto(request);
      print('🔵 서버 저장 완료: ${dto.id}');

      // 3. 로컬 DB에 저장
      await _localSource.savePhoto(dto);

      return dto.toEntity();

    } catch (e) {
      print('🔴 업로드 실패, 대기열 추가: $e');
      return await _addToUploadQueue(albumId, imageFile, message, photoDate);
    }
  }

  @override
  Future<void> deletePhoto(String photoId) async {  // ✅ String
    // TODO: API 구현 시 추가
    throw UnimplementedError('사진 삭제 기능은 준비 중입니다');
  }

  // ========== Private Methods ==========

  /// Photo 리스트를 날짜별로 그룹화하여 Moment 생성
  List<Moment> _groupPhotosByDate(List<Photo> photos) {
    final grouped = <String, List<Photo>>{};

    for (final photo in photos) {
      // ✅ photoDate 사용 (YYYY-MM-DD)
      final date = photo.photoDate;
      grouped.putIfAbsent(date, () => []).add(photo);
    }

    return grouped.entries.map((entry) {
      return Moment(
        date: entry.key,
        photos: entry.value,
        // ✅ uploaderNickname 사용
        contributors: entry.value
            .map((p) => p.uploaderNickname)
            .toSet()
            .toList(),
      );
    }).toList();
  }

  /// 업로드 대기열에 추가 (오프라인 시)
  Future<Photo> _addToUploadQueue(
      String albumId,
      File imageFile,
      String? message,
      String photoDate,
      ) async {
    print('📦 대기열에 추가: $albumId');

    // 임시 Photo 객체 생성
    final now = DateTime.now();
    final tempId = 'temp-${now.millisecondsSinceEpoch}';

    final tempPhoto = PhotoLocal()
      ..photoId = tempId
      ..albumId = albumId
      ..imageUrl = imageFile.path     // 임시로 로컬 경로
      ..thumbnailUrl = imageFile.path
      ..message = message
      ..photoDate = photoDate
      ..uploaderId = _currentUserId
      ..uploaderNickname = _currentUserNickname
      ..uploaderProfileImageUrl = null
      ..createdAt = now
      ..likeCount = 0
      ..commentCount = 0
      ..status = 'pending'            // 대기 중
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