import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/photo_repository.dart';
import '../album/album_list_controller.dart';

enum CameraStep { shooting, review, albumSelect, comment, complete }

class CameraController extends GetxController {
  final PhotoRepository _photoRepository;

  CameraController({required PhotoRepository photoRepository})
      : _photoRepository = photoRepository;

  // ─────────────────────────────────────────
  // Step 상태
  // ─────────────────────────────────────────
  final Rx<CameraStep> step = CameraStep.shooting.obs;

  // ─────────────────────────────────────────
  // STEP 1 - 촬영 (연속 촬영본 누적)
  // ─────────────────────────────────────────
  final RxList<File> capturedImages = <File>[].obs;

  // ─────────────────────────────────────────
  // STEP 2 - 사진 확인 & 셀렉
  // ─────────────────────────────────────────
  final RxList<int> selectedIndices = <int>[].obs;

  // ─────────────────────────────────────────
  // STEP 3 - 앨범 선택
  // ─────────────────────────────────────────
  final Rxn<Album> selectedAlbum = Rxn<Album>();

  // ─────────────────────────────────────────
  // STEP 3.5 - 한줄 추억 코멘트
  // ─────────────────────────────────────────
  final TextEditingController commentController = TextEditingController();

  // ─────────────────────────────────────────
  // STEP 4 - 완료
  // ─────────────────────────────────────────
  final RxBool isUploading = false.obs;
  final RxString completedAlbumTitle = ''.obs;
  final RxString completedAlbumId = ''.obs;
  final RxInt uploadedCount = 0.obs;

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────
  // STEP 1 액션
  // ─────────────────────────────────────────

  /// 라이브 카메라에서 촬영한 파일을 누적한다.
  void addPhoto(File file) {
    capturedImages.add(file);
  }

  void finishShooting() {
    if (capturedImages.isEmpty) return;
    // 선택 상태 초기화 — 유저가 직접 선택
    selectedIndices.clear();
    step.value = CameraStep.review;
  }

  // ─────────────────────────────────────────
  // STEP 2 액션
  // ─────────────────────────────────────────

  void toggleSelect(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
  }

  void selectAll() {
    selectedIndices.assignAll(
      List.generate(capturedImages.length, (i) => i),
    );
  }

  /// 촬영본이 모두 선택된 상태인지
  bool get isAllSelected =>
      capturedImages.isNotEmpty &&
          selectedIndices.length == capturedImages.length;

  /// 전체 선택 ↔ 전체 해제 토글
  void toggleSelectAll() {
    if (isAllSelected) {
      selectedIndices.clear();
    } else {
      selectAll();
    }
  }

  void aiSelect() {
    // TODO: AI 셀렉 로직 — 현재는 전체 선택과 동일하게 처리
    selectAll();
    Get.snackbar('AI 셀렉', 'AI가 최적의 사진을 선택했습니다',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  void goToAlbumSelect() {
    if (selectedIndices.isEmpty) {
      Get.snackbar('알림', '사진을 1장 이상 선택해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    step.value = CameraStep.albumSelect;
  }

  // ─────────────────────────────────────────
  // STEP 3 액션
  // ─────────────────────────────────────────

  void selectAlbum(Album album) {
    selectedAlbum.value = album;
  }

  /// 새 앨범 생성 화면으로 이동.
  /// 생성 성공 시 CreateAlbumController가 AlbumListController.addAlbum()으로
  /// 목록(RxList)에 새 앨범을 넣어주므로, 복귀 후 fetchAlbums로 덮어쓰지 않는다.
  /// (Mock 모드에서 방금 만든 앨범이 서버 목록에 없어 사라지던 문제 방지)
  Future<void> createNewAlbum() async {
    await Get.toNamed(Routes.createAlbum);
  }

  void goToComment() {
    if (selectedAlbum.value == null) {
      Get.snackbar('알림', '앨범을 선택해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    step.value = CameraStep.comment;
  }

  // ─────────────────────────────────────────
  // STEP 3.5 액션 - 코멘트 작성 후 업로드
  // ─────────────────────────────────────────

  Future<void> upload() async {
    final album = selectedAlbum.value;
    if (album == null) {
      Get.snackbar('알림', '앨범을 선택해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final selected = List<int>.from(selectedIndices)..sort();
    final filesToUpload = selected.map((i) => capturedImages[i]).toList();

    // 이번 업로드 배치를 하나로 묶는 momentId (같은 배치 사진 공유)
    final momentId = const Uuid().v4();
    final commentText = commentController.text.trim();
    final message = commentText.isEmpty ? null : commentText;

    isUploading.value = true;
    try {
      final now = DateTime.now();
      final photoDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      for (final file in filesToUpload) {
        await _photoRepository.uploadPhoto(
          albumId: album.id,
          imageFile: file,
          message: message,
          photoDate: photoDate,
          momentId: momentId,
        );
      }

      // 홈 목록 갱신
      if (Get.isRegistered<AlbumListController>()) {
        Get.find<AlbumListController>().fetchAlbums(silent: true);
      }

      completedAlbumTitle.value = album.title;
      completedAlbumId.value = album.id;
      uploadedCount.value = filesToUpload.length;
      step.value = CameraStep.complete;
    } catch (_) {
      Get.snackbar('오류', '업로드에 실패했습니다. 다시 시도해주세요.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  // ─────────────────────────────────────────
  // STEP 4 액션
  // ─────────────────────────────────────────

  void goToAlbum() {
    final albumId = completedAlbumId.value;
    final album = selectedAlbum.value;
    _reset();
    // 홈을 스택 최하단에 두고 그 위에 앨범 상세를 띄운다.
    // (offAllNamed로 앨범 상세만 남기면 back 시 돌아갈 화면이 없어 동작하지 않음)
    Get.offAllNamed(Routes.home);
    Get.toNamed(
      Routes.albumDetail,
      arguments: {
        'albumId': albumId,
        'album': album,
      },
    );
  }

  void continueShooting() {
    _reset();
    step.value = CameraStep.shooting;
  }

  // ─────────────────────────────────────────
  // 내부
  // ─────────────────────────────────────────

  void deleteLastPhoto() {
    if (capturedImages.isEmpty) return;
    capturedImages.removeLast();
    selectedIndices.remove(capturedImages.length);
  }

  /// 특정 인덱스의 촬영본 삭제 (Step1 스택 브라우징에서 사용)
  void deletePhotoAt(int index) {
    if (index < 0 || index >= capturedImages.length) return;
    capturedImages.removeAt(index);
  }

  void clearAllPhotos() {
    capturedImages.clear();
    selectedIndices.clear();
  }

  void _reset() {
    capturedImages.clear();
    selectedIndices.clear();
    selectedAlbum.value = null;
    commentController.clear();
    uploadedCount.value = 0;
  }

  void onTabResumed() {
    if (step.value == CameraStep.complete) {
      _reset();
      step.value = CameraStep.shooting;
    }
  }

  List<Album> sortedAlbums() {
    if (!Get.isRegistered<AlbumListController>()) return [];
    final albums = List<Album>.from(
      Get.find<AlbumListController>().albums,
    );
    albums.sort((a, b) {
      final aTime = a.lastPhotoUploadedAt ?? a.createdAt;
      final bTime = b.lastPhotoUploadedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return albums;
  }
}