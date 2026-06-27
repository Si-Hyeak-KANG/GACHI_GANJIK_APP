import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/album/create_album_controller.dart';
import '../../widgets/album/cover_image_picker.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class CreateAlbumView extends GetView<CreateAlbumController> {
  const CreateAlbumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
          onPressed: Get.back,
        ),
        title: const Text(
          '사진첩 만들기',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 커버 사진
                Obx(() => CoverImagePicker(
                  selectedImage: controller.selectedCoverImage.value,
                  onTap: controller.pickCoverImage,
                  onRemove: controller.selectedCoverImage.value != null
                      ? controller.removeCoverImage
                      : null,
                )),
                const SizedBox(height: 28),

                // 앨범 이름
                CustomTextField(
                  label: '사진첩 이름',
                  hint: '예) 우리의 결혼식, 제주 여행',
                  controller: controller.titleController,
                  validator: controller.validateTitle,
                  isRequired: true,
                ),
                const SizedBox(height: 24),

                // 카테고리
                const _SectionLabel(label: '카테고리', isRequired: true),
                const SizedBox(height: 10),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CreateAlbumController.categories.map((cat) {
                    final isSelected = controller.selectedCategories.contains(cat);
                    return GestureDetector(
                      onTap: () => controller.selectCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.main : AppColors.mainLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.main,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 24),

                // 시작 날짜
                const _SectionLabel(label: '이벤트 시작', isRequired: true),
                const SizedBox(height: 10),
                Obx(() => _DateField(
                  value: controller.selectedStartDate.value,
                  hint: '시작 날짜를 선택해주세요',
                  enabled: true,
                  onTap: () => controller.pickStartDate(context),
                  formatDisplay: controller.formatDateForDisplay,
                )),
                const SizedBox(height: 16),

                const _SectionLabel(label: '이벤트 종료', isOptional: true),
                const SizedBox(height: 10),
                Obx(() => _DateField(
                  value: controller.selectedEndDate.value,
                  hint: '종료 날짜를 선택해주세요',
                  enabled: controller.selectedStartDate.value.isNotEmpty,
                  onTap: () => controller.pickEndDate(context),
                  formatDisplay: controller.formatDateForDisplay,
                )),
                const SizedBox(height: 40),

                // 생성 버튼
                Obx(() {
                  final isValid = controller.titleText.value.trim().length >= 2 &&
                      controller.selectedCategories.isNotEmpty &&
                      controller.selectedStartDate.value.isNotEmpty;
                  return CustomButton(
                    text: '사진첩 만들기',
                    isLoading: controller.isLoading.value,
                    onTap: isValid ? controller.createAlbum : null,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String value;
  final String hint;
  final bool enabled;
  final VoidCallback onTap;
  final String Function(String) formatDisplay;

  const _DateField({
    required this.value,
    required this.hint,
    required this.enabled,
    required this.onTap,
    required this.formatDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFFAFAFA),
          border: Border.all(color: enabled ? const Color(0xFFE8E8E8) : const Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18,
                color: enabled ? AppColors.textSecondary : AppColors.inactive),
            const SizedBox(width: 10),
            Text(
              value.isEmpty ? hint : formatDisplay(value),
              style: TextStyle(
                fontSize: 15,
                color: value.isEmpty ? AppColors.inactive : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isOptional;
  final bool isRequired;
  final String? subLabel;

  const _SectionLabel({
    required this.label,
    this.isOptional = false,
    this.isRequired = false,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text('*', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.main)),
        ],
        if (isOptional) ...[
          const SizedBox(width: 6),
          const Text('(선택)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
        if (subLabel != null) ...[
          const SizedBox(width: 6),
          Text('($subLabel)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}