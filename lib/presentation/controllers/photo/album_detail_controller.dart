import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/repositories/photo_repository.dart';
import '../../../core/network/network_exception.dart';

class AlbumDetailController extends GetxController {
  final PhotoRepository _photoRepository;
  final int albumId;

  AlbumDetailController({
    required PhotoRepository photoRepository,
    required this.albumId,
  }) : _photoRepository = photoRepository;

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
      Get.snackbar('오류', '사진을 불러오지 못했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // 카메라에서 촬영
  Future<void> pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      _showMessageDialog(File(image.path));
    }
  }

  // 갤러리에서 선택
  Future<void> pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      _showMessageDialog(File(image.path));
    }
  }

  // 메시지 입력 다이얼로그 표시
  void _showMessageDialog(File imageFile) {
    Get.dialog(
      _MessageInputDialog(
        onSubmit: (message) => _uploadPhoto(imageFile, message),
      ),
      barrierDismissible: false,
    );
  }

  // 사진 업로드
  Future<void> _uploadPhoto(File imageFile, String? message) async {
    Get.back(); // 다이얼로그 닫기
    isUploading.value = true;

    try {
      final photo = await _photoRepository.uploadPhoto(
        albumId: albumId,
        imageFile: imageFile,
        message: message,
      );

      // 목록 갱신
      await fetchMoments();

      Get.snackbar(
        '업로드 완료',
        '사진이 추가되었습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on NetworkException catch (e) {
      Get.snackbar('업로드 실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('오류', '사진 업로드에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }
}

// 메시지 입력 다이얼로그 위젯
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