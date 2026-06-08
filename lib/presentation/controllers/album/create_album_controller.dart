import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/sources/firebase/firebase_storage_source.dart';
import '../album/album_list_controller.dart';

class CreateAlbumController extends GetxController {
  final AlbumRepository _albumRepository;
  final FirebaseStorageSource _storageSource;

  CreateAlbumController({
    required AlbumRepository albumRepository,
    required FirebaseStorageSource storageSource,
  })  : _albumRepository = albumRepository,
        _storageSource = storageSource;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();

  final RxList<String> selectedCategories = <String>[].obs;
  final RxString selectedStartDate = ''.obs;
  final RxString selectedEndDate = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString titleText = ''.obs;
  final Rxn<File> selectedCoverImage = Rxn<File>(); // 커버 사진

  final _picker = ImagePicker();

  static const List<String> categories = [
    '결혼', '여행', '모임', '생일', '기념일', '연인', '반려동물',
    '취미', '일상', '기록', '친구', '독서', '공부', '기타',
  ];

  @override
  void onInit() {
    super.onInit();
    titleController.addListener(() {
      titleText.value = titleController.text;
    });
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  // ── 커버 사진 선택 ──────────────────────────────
  Future<void> pickCoverImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      selectedCoverImage.value = File(image.path);
    }
  }

  void removeCoverImage() {
    selectedCoverImage.value = null;
  }

  void selectCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      if (selectedCategories.length < 3) {
        selectedCategories.add(category);
      } else {
        Get.snackbar('알림', '카테고리는 최대 3개까지 선택할 수 있습니다',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      }
    }
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF6F7D)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted = _formatDate(picked);
      selectedStartDate.value = formatted;
      if (selectedEndDate.value.isNotEmpty) {
        final end = _parseDate(selectedEndDate.value);
        if (end != null && end.isBefore(picked)) {
          selectedEndDate.value = '';
          Get.snackbar('알림', '종료 날짜가 시작 날짜보다 이전이어서 초기화되었습니다',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2));
        }
      }
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    if (selectedStartDate.value.isEmpty) {
      Get.snackbar('알림', '시작 날짜를 먼저 선택해주세요',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      return;
    }
    final startDate = _parseDate(selectedStartDate.value) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF6F7D)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      selectedEndDate.value = _formatDate(picked);
    }
  }

  Future<void> createAlbum() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCategories.isEmpty) {
      Get.snackbar('알림', '카테고리를 최소 1개 선택해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedStartDate.value.isEmpty) {
      Get.snackbar('알림', '이벤트 시작 날짜를 선택해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // 커버 사진 Firebase 업로드
      String? coverImageUrl;
      if (selectedCoverImage.value != null) {
        coverImageUrl = await _storageSource.uploadCoverImage(
          selectedCoverImage.value!,
          'covers',
        );
      }

      final album = await _albumRepository.createAlbum(
        title: titleController.text.trim(),
        categories: selectedCategories.toList(),
        eventStartDate: selectedStartDate.value,
        eventEndDate: selectedEndDate.value.isEmpty ? null : selectedEndDate.value,
        coverImageUrl: coverImageUrl,
      );

      if (Get.isRegistered<AlbumListController>()) {
        Get.find<AlbumListController>().addAlbum(album);
      }

      Get.back();
      Get.snackbar('생성 완료', '${album.title} 사진첩이 만들어졌습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('오류', '사진첩 생성에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
    } finally {
      isLoading.value = false;
    }
  }

  String formatDateForDisplay(String apiDate) =>
      apiDate.isEmpty ? '' : apiDate.replaceAll('-', '.');

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {
      return null;
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return '사진첩 이름을 입력해주세요';
    if (value.trim().length < 2) return '2자 이상 입력해주세요';
    return null;
  }
}