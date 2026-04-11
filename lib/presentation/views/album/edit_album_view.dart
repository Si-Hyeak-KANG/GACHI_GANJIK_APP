import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/album/edit_album_controller.dart';
import '../../widgets/album/cover_image_picker.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class EditAlbumView extends GetView<EditAlbumController> {
  const EditAlbumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('앨범 정보 수정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커버 사진
            Obx(() => CoverImagePicker(
              selectedImage: controller.selectedCoverImage.value,
              existingImageUrl: controller.existingCoverImageUrl.value,
              onTap: controller.pickCoverImage,
              onRemove: (controller.selectedCoverImage.value != null ||
                  (controller.existingCoverImageUrl.value?.isNotEmpty ?? false))
                  ? controller.removeCoverImage
                  : null,
            )),
            const SizedBox(height: 24),

            // 앨범 이름
            CustomTextField(
              controller: controller.titleController,
              label: '앨범 이름',
              hint: '앨범 이름을 입력해주세요',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '앨범 이름을 입력해주세요';
                if (v.trim().length < 2) return '2자 이상 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 카테고리
            const Text('카테고리',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EditAlbumController.categories.map((cat) {
                final selected = controller.selectedCategories.contains(cat);
                return GestureDetector(
                  onTap: () => controller.toggleCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.main : AppColors.mainLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : AppColors.main,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 24),

            // 날짜
            const Text('이벤트 날짜',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _DateButton(
                    label: controller.selectedStartDate.value.isEmpty
                        ? '시작 날짜'
                        : controller.formatDateForDisplay(controller.selectedStartDate.value),
                    onTap: () => controller.pickStartDate(context),
                  )),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('~', style: TextStyle(color: AppColors.textSecondary)),
                ),
                Expanded(
                  child: Obx(() => _DateButton(
                    label: controller.selectedEndDate.value.isEmpty
                        ? '종료 날짜 (선택)'
                        : controller.formatDateForDisplay(controller.selectedEndDate.value),
                    onTap: () => controller.pickEndDate(context),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 저장 버튼
            Obx(() => CustomButton(
              text: '저장',
              onTap: controller.saveAlbum,
              isLoading: controller.isLoading.value,
            )),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ),
    );
  }
}