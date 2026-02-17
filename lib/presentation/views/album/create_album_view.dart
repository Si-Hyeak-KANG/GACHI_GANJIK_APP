import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/album/create_album_controller.dart';
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: Get.back,
        ),
        title: const Text(
          '사진첩 만들기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
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
                // 커버 이미지 placeholder
                // 왜 Phase 2에 추가? → UX 흐름 완성, 실제 업로드는 Phase 3에서
                GestureDetector(
                  onTap: () => Get.snackbar(
                    '준비 중',
                    '커버 이미지 업로드는 Phase 3에서 구현됩니다',
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.mainLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.inactive,
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: AppColors.inactive,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '커버 사진 (선택)',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 앨범 이름 (필수)
                CustomTextField(
                  label: '사진첩 이름',
                  hint: '예) 우리의 결혼식, 제주 여행',
                  controller: controller.titleController,
                  validator: controller.validateTitle,
                  isRequired: true,
                ),
                const SizedBox(height: 24),

                // 카테고리 (선택)
                const _SectionLabel(
                  label: '카테고리',
                  isOptional: true,
                ),
                const SizedBox(height: 10),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CreateAlbumController.categories.map((cat) {
                    final isSelected = controller.selectedCategory.value == cat;
                    return GestureDetector(
                      onTap: () => controller.selectCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
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

                // 이벤트 날짜 (선택)
                const _SectionLabel(
                  label: '이벤트 날짜',
                  isOptional: true,
                ),
                const SizedBox(height: 10),
                Obx(() => GestureDetector(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          controller.selectedDate.value.isEmpty
                              ? '날짜를 선택해주세요'
                              : controller.selectedDate.value,
                          style: TextStyle(
                            fontSize: 15,
                            color: controller.selectedDate.value.isEmpty
                                ? AppColors.inactive
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: 8),
                const Text(
                  '이 날의 기억부터 차곡차곡 모아볼게요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // 생성 버튼
                Obx(() => CustomButton(
                  text: '사진첩 만들기',
                  isLoading: controller.isLoading.value,
                  onTap: controller.createAlbum,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isOptional;

  const _SectionLabel({required this.label, this.isOptional = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isOptional) ...[
          const SizedBox(width: 6),
          const Text(
            '(선택)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}