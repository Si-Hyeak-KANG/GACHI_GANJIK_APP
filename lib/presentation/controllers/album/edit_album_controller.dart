import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/sources/firebase/firebase_storage_source.dart';
import '../album/album_list_controller.dart';

class EditAlbumController extends GetxController {
  final AlbumRepository _albumRepository;
  final FirebaseStorageSource _storageSource;
  final Album album;

  EditAlbumController({
    required AlbumRepository albumRepository,
    required FirebaseStorageSource storageSource,
    required this.album,
  })  : _albumRepository = albumRepository,
        _storageSource = storageSource;

  late final TextEditingController titleController;
  final RxList<String> selectedCategories = <String>[].obs;
  final RxString selectedStartDate = ''.obs;
  final RxString selectedEndDate = ''.obs;
  final RxBool isLoading = false.obs;
  final Rxn<File> selectedCoverImage = Rxn<File>(); // 새로 선택한 커버 사진
  // 기존 커버 URL (새 사진 선택 전까지 유지)
  late final RxnString existingCoverImageUrl;

  final _picker = ImagePicker();

  static const List<String> categories = [
    '결혼', '여행', '모임', '생일', '기념일', '연인', '반려동물',
    '취미', '일상', '기록', '친구', '독서', '공부', '기타',
  ];

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController(text: album.title);
    selectedCategories.assignAll(album.categories);
    selectedStartDate.value = album.eventStartDate;
    selectedEndDate.value = album.eventEndDate ?? '';
    existingCoverImageUrl = RxnString(album.coverImageUrl);
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
      existingCoverImageUrl.value = null; // 기존 URL 무효화
    }
  }

  void removeCoverImage() {
    selectedCoverImage.value = null;
    existingCoverImageUrl.value = null;
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories
        ..clear()
        ..add(category);
    }
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(selectedStartDate.value) ?? DateTime.now(),
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
      selectedStartDate.value = _formatDate(picked);
      if (selectedEndDate.value.isNotEmpty) {
        final end = _parseDate(selectedEndDate.value);
        if (end != null && end.isBefore(picked)) {
          selectedEndDate.value = '';
        }
      }
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    if (selectedStartDate.value.isEmpty) {
      Get.snackbar('알림', '시작 날짜를 먼저 선택해주세요',
          snackPosition: SnackPosition.BOTTOM);
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

  Future<void> saveAlbum() async {
    final title = titleController.text.trim();
    if (title.length < 2) {
      Get.snackbar('알림', '앨범 이름은 2자 이상이어야 합니다',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedCategories.isEmpty) {
      Get.snackbar('알림', '카테고리를 선택해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedStartDate.value.isEmpty) {
      Get.snackbar('알림', '시작 날짜를 선택해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // 새 커버 사진 선택 시 Firebase 업로드
      String? coverImageUrl = existingCoverImageUrl.value;
      if (selectedCoverImage.value != null) {
        coverImageUrl = await _storageSource.uploadCoverImage(
          selectedCoverImage.value!,
          'covers',
        );
      }

      final updatedAlbum = await _albumRepository.updateAlbum(
        albumId: album.id,
        title: title,
        categories: selectedCategories.toList(),
        eventStartDate: selectedStartDate.value,
        eventEndDate: selectedEndDate.value.isEmpty ? null : selectedEndDate.value,
        coverImageUrl: coverImageUrl,
      );

      if (Get.isRegistered<AlbumListController>()) {
        final listController = Get.find<AlbumListController>();
        final index = listController.albums.indexWhere((a) => a.id == album.id);
        if (index != -1) listController.albums[index] = updatedAlbum;
      }

      Get.back(result: updatedAlbum);
      Get.snackbar('완료', '앨범 정보가 수정되었습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
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
}