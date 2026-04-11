import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../domain/repositories/photo_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import '../album/album_list_controller.dart';
import '../network/network_controller.dart';

class AlbumDetailController extends GetxController {
  final PhotoRepository _photoRepository;
  final AlbumRepository _albumRepository;
  final String albumId;

  AlbumDetailController({
    required PhotoRepository photoRepository,
    required AlbumRepository albumRepository,
    required this.albumId,
  })  : _photoRepository = photoRepository,
        _albumRepository = albumRepository;

  final RxList<Moment> moments = <Moment>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchMoments();
  }

  Future<void> fetchMoments() async {
    isLoading.value = true;
    try {
      final result = await _photoRepository.getAlbumMoments(albumId);
      moments.assignAll(result);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('오류', '사진을 불러오지 못했습니다', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── 커버 사진 등록 ──────────────────────────────
  Future<void> pickCoverImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image == null) return;

    isUploading.value = true;
    try {
      // TODO: Firebase Storage 업로드 후 URL 획득
      // 현재는 로컬 경로를 임시 URL로 사용
      // Photos API 연동 후 FirebaseStorageSource.uploadImage() 호출로 교체
      Get.snackbar('준비 중', '커버 사진 등록은 앨범 수정 API 연동 후 지원됩니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  // ── 앨범 삭제 (OWNER만) ──────────────────────────
  Future<void> deleteAlbum() async {
    try {
      await _albumRepository.deleteAlbum(albumId);
      // 앨범 목록에서 제거
      if (Get.isRegistered<AlbumListController>()) {
        Get.find<AlbumListController>().albums.removeWhere((a) => a.id == albumId);
      }
      Get.until((route) => route.settings.name == Routes.home);
      Get.snackbar('삭제 완료', '앨범이 삭제되었습니다', snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── 앨범 나가기 (MEMBER/ADMIN) ───────────────────
  Future<void> leaveAlbum() async {
    try {
      await _albumRepository.leaveAlbum(albumId);
      if (Get.isRegistered<AlbumListController>()) {
        Get.find<AlbumListController>().albums.removeWhere((a) => a.id == albumId);
      }
      Get.until((route) => route.settings.name == Routes.home);
      Get.snackbar('완료', '앨범에서 나왔습니다', snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── 사진 업로드 ──────────────────────────────────
  Future<void> pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) _showMessageDialog(File(image.path));
  }

  Future<void> pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) _showMessageDialog(File(image.path));
  }

  void _showMessageDialog(File imageFile) {
    Get.dialog(
      _MessageInputDialog(onSubmit: (message) => _uploadPhoto(imageFile, message)),
      barrierDismissible: false,
    );
  }

  Future<void> _uploadPhoto(File imageFile, String? message) async {
    Get.back();
    isUploading.value = true;
    try {
      final now = DateTime.now();
      final photoDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await _photoRepository.uploadPhoto(
        albumId: albumId,
        imageFile: imageFile,
        message: message,
        photoDate: photoDate,
      );

      await fetchMoments();
      Get.snackbar('업로드 완료', '사진이 추가되었습니다', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('오류', '사진 업로드에 실패했습니다', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }
}

class _MessageInputDialog extends StatelessWidget {
  final Function(String?) onSubmit;

  const _MessageInputDialog({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('메시지 추가 (선택)'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: '이 순간에 대한 메시지를 남겨보세요',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        maxLength: 100,
      ),
      actions: [
        TextButton(
          onPressed: () => onSubmit(null),
          child: const Text('건너뛰기'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();
            onSubmit(text.isEmpty ? null : text);
          },
          child: const Text('업로드'),
        ),
      ],
    );
  }
}