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

  final RxList<String> selectedCategories = <String>[].obs;
  final RxString selectedStartDate = ''.obs;
  final RxString selectedEndDate = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString titleText = ''.obs;

  RxBool get isFormValid => (
      titleController.text.trim().length >= 2 &&
          selectedCategories.isNotEmpty &&
          selectedStartDate.value.isNotEmpty
  ).obs;

  static const List<String> categories = [
    '결혼', '여행', '모임', '생일', '기념일', '연인', '반려동물', '취미', '일상', '기록', '친구', '독서', '공부','기타',
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

  void selectCategory(String category) {
    if (selectedCategories.contains(category)) {
      // 이미 선택됨 → 해제
      selectedCategories.remove(category);
    } else {
      // 선택되지 않음 → 추가 (단, 최대 3개)
      if (selectedCategories.length < 3) {
        selectedCategories.add(category);
      } else {
        Get.snackbar(
          '알림',
          '카테고리는 최대 3개까지 선택할 수 있습니다',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> pickStartDate(BuildContext context) async {
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
      selectedStartDate.value = formatted;

      // ✅ 추가: 종료 날짜가 시작 날짜보다 이전이면 초기화
      if (selectedEndDate.value.isNotEmpty) {
        if (_compareDates(selectedEndDate.value, formatted) < 0) {
          selectedEndDate.value = '';
          Get.snackbar(
            '알림',
            '종료 날짜가 시작 날짜보다 이전이어서 초기화되었습니다',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      }
    }
  }

  // ✅ 추가: 종료 날짜 선택
  Future<void> pickEndDate(BuildContext context) async {
    if (selectedStartDate.value.isEmpty) {
      Get.snackbar(
        '알림',
        '시작 날짜를 먼저 선택해주세요',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // 시작 날짜를 DateTime으로 변환
    final startDate = _parseDate(selectedStartDate.value);

    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate, // ✅ 시작 날짜 이후만 선택 가능
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
      selectedEndDate.value = formatted;
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('.');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  int _compareDates(String date1, String date2) {
    final d1 = _parseDate(date1);
    final d2 = _parseDate(date2);
    return d1.compareTo(d2);
  }

  // 앨범 생성
  Future<void> createAlbum() async {
    print('🔵 CreateAlbumController.createAlbum 시작');

    if (!formKey.currentState!.validate()) {
      print('⚠️ 폼 검증 실패');
      return;
    }

    // 추가 검증
    if (selectedCategories.isEmpty) {
      Get.snackbar(
        '알림',
        '카테고리를 최소 1개 선택해주세요',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedStartDate.value.isEmpty) {
      Get.snackbar(
        '알림',
        '이벤트 시작 날짜를 선택해주세요',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    print('  title: ${titleController.text.trim()}');
    print('  categories: ${selectedCategories.toList()}');
    print('  eventStartDate: ${selectedStartDate.value}');
    print('  eventEndDate: ${selectedEndDate.value}');

    isLoading.value = true;
    try {
      final album = await _albumRepository.createAlbum(
        title: titleController.text.trim(),
        categories: selectedCategories.toList(),
        eventStartDate: selectedStartDate.value,
        eventEndDate: selectedEndDate.value.isEmpty ? null : selectedEndDate.value,
      );

      print('🟢 앨범 생성 성공: ${album.id} - ${album.title}');

      if (Get.isRegistered<AlbumListController>()) {
        print('🟢 AlbumListController에 앨범 추가');
        Get.find<AlbumListController>().addAlbum(album);
      } else {
        print('⚠️ AlbumListController가 등록되지 않음');
      }

      Get.back();
      Get.snackbar(
        '생성 완료',
        '${album.title} 사진첩이 만들어졌습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on NetworkException catch (e) {
      print('🔴 NetworkException: ${e.message}');
      Get.snackbar('실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e, stackTrace) {
      print('🔴 CreateAlbumController 에러: $e');
      print('🔴 StackTrace: $stackTrace');

      Get.snackbar(
        '오류',
        '사진첩 생성에 실패했습니다\n$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
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