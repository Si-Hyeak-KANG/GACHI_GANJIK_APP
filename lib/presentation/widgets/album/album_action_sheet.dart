import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';

class AlbumActionSheet extends StatelessWidget {
  const AlbumActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 액션 카드
          Container(
            constraints: const BoxConstraints(
              minHeight: 320,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [

                const SizedBox(height: 12),
                // 핸들바
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.inactive,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 앨범 만들기
                _ActionRow(
                  icon: Icons.create_new_folder_outlined,
                  title: '앨범 만들기',
                  subtitle: '사진을 함께 모으고 추억을 기록해보세요.',
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.createAlbum);
                  },
                ),

                const SizedBox(height: 18),

                // 앨범 참여하기
                _ActionRow(
                  icon: Icons.group_add_outlined,
                  title: '앨범 참여하기',
                  subtitle: '초대 코드를 입력하여 앨범에 참여하세요.',
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.guestEntry);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),


        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal:16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xffEEEEEE),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  color: AppColors.main.withOpacity(.08),
                shape: BoxShape.circle
              ),
              child: Icon(icon, size: 24, color: AppColors.main),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size:14,
              color: AppColors.inactive,
            ),
          ],
        ),
      ),
    );
  }
}