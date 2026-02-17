import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../core/network/network_exception.dart';
import '../album/album_list_controller.dart';

class CreateAlbumController extends GetxController {
  final AlbumRepository _albumRepository;

  CreateAlbumController({required AlbumRepository albumRepository})
      : _albumRepository = albumRepository;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();

  final RxString selectedCategory = ''.obs;
  final RxString selectedDate = ''.obs;
  final RxBool isLoading = false.obs;

  static const List<String> categories = [
    '결혼식', '여행', '모임', '생일', '기념일', '기타',
  ];

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  void selectCategory(String category) {
    // 같은 카테고리 재선택 시 해제
    if (selectedCategory.value == category) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = category;
    }
  }

  void selectDate(String date) {
    selectedDate.value = date;
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6F7D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.year}.${picked.month.toString().padLeft(2, '0')}.${picked.day.toString().padLeft(2, '0')}';
      selectedDate.value = formatted;
    }
  }

  Future<void> createAlbum() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final album = await _albumRepository.createAlbum(
        title: titleController.text.trim(),
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        eventDate: selectedDate.value.isEmpty ? null : selectedDate.value,
      );

      // AlbumListController가 등록되어 있으면 목록에 추가
      if (Get.isRegistered<AlbumListController>()) {
        Get.find<AlbumListController>().addAlbum(album);
      }

      Get.back();
      Get.snackbar(
        '생성 완료',
        '${album.title} 사진첩이 만들어졌습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on NetworkException catch (e) {
      Get.snackbar('실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('오류', '사진첩 생성에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return '사진첩 이름을 입력해주세요';
    if (value.trim().length < 2) return '2자 이상 입력해주세요';
    return null;
  }
}