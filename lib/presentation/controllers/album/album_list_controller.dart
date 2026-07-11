import 'package:get/get.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/services/websocket_service.dart';
import '../../../data/models/album/album_event.dart';

class AlbumListController extends GetxController {
  final AlbumRepository _albumRepository;
  final WebSocketService _wsService;

  AlbumListController({
    required AlbumRepository albumRepository,
    required WebSocketService wsService,
  })  : _albumRepository = albumRepository,
        _wsService = wsService;

  final RxList<Album> albums = <Album>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isJoining = false.obs;

  // 새 활동이 감지된 albumId 집합 — 뱃지 표시용
  final RxSet<String> updatedAlbumIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAlbums();
  }

  @override
  void onClose() {
    _wsService.unsubscribeAll();
    super.onClose();
  }

  // ─────────────────────────────────────────
  // 앨범 목록 조회
  // ─────────────────────────────────────────

  Future<void> fetchAlbums() async {
    isLoading.value = true;
    try {
      final result = await _albumRepository.getAlbums();
      result.sort((a, b) {
        final aTime = a.lastPhotoUploadedAt ?? a.createdAt;
        final bTime = b.lastPhotoUploadedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      albums.assignAll(result);
      _subscribeToAllAlbums();
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('오류', '앨범 목록을 불러오지 못했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────
  // WebSocket 구독
  // ─────────────────────────────────────────

  void _subscribeToAllAlbums() {
    _wsService.unsubscribeAll();
    for (final album in albums) {
      _wsService.subscribeToAlbum(album.id, (event) {
        _onAlbumEvent(event);
      });
    }
  }

  void _onAlbumEvent(AlbumEvent event) {
    if (event.type != 'PHOTO_UPLOADED') return;

    final index = albums.indexWhere((a) => a.id == event.albumId);
    if (index == -1) return;

    final existing = albums[index];

    // lastPhotoUploadedAt, photoCount 업데이트
    final updated = Album(
      id: existing.id,
      title: existing.title,
      categories: existing.categories,
      eventStartDate: existing.eventStartDate,
      eventEndDate: existing.eventEndDate,
      coverImageUrl: existing.coverImageUrl,
      inviteCode: existing.inviteCode,
      photoCount: event.photoCount,
      memberCount: existing.memberCount,
      createdAt: existing.createdAt,
      updatedAt: existing.updatedAt,
      lastPhotoUploadedAt: event.lastPhotoUploadedAt,
      ownerId: existing.ownerId,
      currentUserId: existing.currentUserId,
      role: existing.role,
      isAdmin: existing.isAdmin,
    );

    // 목록 업데이트 후 맨 앞으로 이동
    albums.removeAt(index);
    albums.insert(0, updated);

    // 뱃지 표시
    updatedAlbumIds.add(event.albumId);
  }

  // 뱃지 제거 (앨범 진입 시 호출)
  void clearBadge(String albumId) {
    updatedAlbumIds.remove(albumId);
  }

  // ─────────────────────────────────────────
  // 앨범 입장
  // ─────────────────────────────────────────

  Future<void> joinAlbum(String inviteCode) async {
    if (inviteCode.trim().isEmpty) {
      Get.snackbar('알림', '초대 코드를 입력해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isJoining.value = true;
    try {
      final album = await _albumRepository.joinAlbum(inviteCode.trim());
      final exists = albums.any((a) => a.id == album.id);
      if (!exists) {
        albums.insert(0, album);
        _wsService.subscribeToAlbum(album.id, _onAlbumEvent);
      }
      Get.back();
      Get.snackbar('입장 완료', '${album.title}에 참여했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isJoining.value = false;
    }
  }

  void addAlbum(Album album) {
    albums.insert(0, album);
    _wsService.subscribeToAlbum(album.id, _onAlbumEvent);
  }
}