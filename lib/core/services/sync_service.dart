import 'dart:io';
import 'package:get/get.dart';
import '../../data/sources/local/photo_local_source.dart';
import '../../domain/repositories/album_repository.dart';
import '../../domain/repositories/photo_repository.dart';
import '../storage/database/database_service.dart';
import '../storage/database/album_local.dart';

class SyncService extends GetxService {
  final AlbumRepository _albumRepository;
  final PhotoRepository _photoRepository;
  final PhotoLocalSource _photoLocalSource;

  SyncService({
    required AlbumRepository albumRepository,
    required PhotoRepository photoRepository,
    required PhotoLocalSource photoLocalSource,
  })  : _albumRepository = albumRepository,
        _photoRepository = photoRepository,
        _photoLocalSource = photoLocalSource;

  final RxBool isSyncing = false.obs;

  // 전체 동기화
  Future<void> syncAll() async {
    if (isSyncing.value) return;

    isSyncing.value = true;
    try {
      // 1. 서버 → 로컬 동기화 (서버 우선)
      await syncAlbumsFromServer();

      // 2. 업로드 대기열 처리
      await processPendingUploads();

      Get.snackbar(
        '동기화 완료',
        '모든 데이터가 최신 상태입니다',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '동기화 실패',
        '일부 데이터 동기화에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  // 서버에서 앨범 목록 동기화
  Future<void> syncAlbumsFromServer() async {
    try {
      // 서버에서 앨범 목록 가져오기
      final albums = await _albumRepository.getAlbums();

      // 로컬 DB에 저장 (서버 우선 - 덮어쓰기)
      for (final album in albums) {
        final local = AlbumLocal()
          ..albumId = album.id
          ..title = album.title
          ..category = album.category
          ..eventDate = album.eventDate
          ..coverImage = album.coverImage
          ..inviteCode = album.inviteCode
          ..photoCount = album.photoCount
          ..memberCount = album.memberCount
          ..createdAt = DateTime.parse(album.createdAt)
          ..lastSyncedAt = DateTime.now()
          ..syncStatus = 'synced';

        await DatabaseService.saveAlbum(local);
      }
    } catch (e) {
      print('앨범 동기화 실패: $e');
    }
  }

  // 업로드 대기열 처리
  Future<void> processPendingUploads() async {
    try {
      final pendingPhotos = await _photoLocalSource.getPendingPhotos();

      for (final photo in pendingPhotos) {
        try {
          // 로컬 파일이 있으면 업로드 재시도
          if (photo.localPath != null) {
            final file = File(photo.localPath!);
            if (await file.exists()) {
              // PhotoRepository를 통해 업로드
              await _photoRepository.uploadPhoto(
                albumId: photo.albumId,
                imageFile: file,
                message: photo.message,
              );

              // 성공 시 상태 업데이트
              photo.status = 'synced';
              photo.localPath = null;
              photo.retryCount = 0;

              await _photoLocalSource.savePhotoLocal(photo);

              // 로컬 파일 삭제
              await file.delete();
            } else {
              // 파일이 없으면 실패 처리
              photo.status = 'failed';
              await _photoLocalSource.savePhotoLocal(photo);
            }
          }
        } catch (e) {
          // 재시도 횟수 증가
          photo.retryCount++;
          photo.lastSyncAttempt = DateTime.now();

          // 3회 이상 실패 시 포기
          if (photo.retryCount >= 3) {
            photo.status = 'failed';
          }

          await _photoLocalSource.savePhotoLocal(photo);
          print('사진 업로드 실패: $e');
        }
      }
    } catch (e) {
      print('대기열 처리 실패: $e');
    }
  }
}