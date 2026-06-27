import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/album/category_album_list_controller.dart';
import '../../widgets/album/album_action_sheet.dart';
import '../../widgets/common/empty_state.dart';

class CategoryAlbumListView extends GetView<CategoryAlbumListController> {
  const CategoryAlbumListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => const AlbumActionSheet(),
        ),
        backgroundColor: AppColors.textPrimary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 20, color: AppColors.textPrimary),
                    onPressed: Get.back,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.category,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Obx(() => Text(
                          '총 ${controller.albums.length}개 앨범',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 정렬 칩
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SortChip(
                      label: '최신 업로드',
                      isActive: controller.sortType.value == AlbumSortType.latest,
                      onTap: () => controller.setSort(AlbumSortType.latest),
                    ),
                    const SizedBox(width: 8),
                    _SortChip(
                      label: '추억 날짜',
                      isActive: controller.sortType.value == AlbumSortType.eventDate,
                      onTap: () => controller.setSort(AlbumSortType.eventDate),
                    ),
                    const SizedBox(width: 8),
                    _SortChip(
                      label: '이름순',
                      isActive: controller.sortType.value == AlbumSortType.name,
                      onTap: () => controller.setSort(AlbumSortType.name),
                    ),
                    const SizedBox(width: 8),
                    _SortChip(
                      label: '사진수',
                      isActive: controller.sortType.value == AlbumSortType.photoCount,
                      onTap: () => controller.setSort(AlbumSortType.photoCount),
                    ),
                  ],
                ),
              )),
            ),

            // 앨범 목록
            Expanded(
              child: Obx(() {
                if (controller.albums.isEmpty) {
                  return EmptyState(
                    icon: Icons.photo_album_outlined,
                    message: '앨범이 없어요',
                    subMessage: '${controller.category} 카테고리 앨범이 없습니다',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: controller.albums.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final album = controller.albums[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        Routes.albumDetail,
                        arguments: {
                          'album': album,
                          'albumId': album.id,
                        },
                      ),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.cardBg,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 썸네일
                            if (album.coverImageUrl != null &&
                                album.coverImageUrl!.trim().isNotEmpty)
                              Image.network(
                                album.coverImageUrl!.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _GradientBackground(
                                        categories: album.categories),
                              )
                            else
                              _GradientBackground(
                                  categories: album.categories),

                            // 딤
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0xCC000000),
                                  ],
                                  stops: [0.35, 1.0],
                                ),
                              ),
                            ),

                            // 텍스트
                            Positioned(
                              left: 14,
                              right: 14,
                              bottom: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    album.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          album.eventDateDisplay,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.photo_outlined,
                                              size: 12, color: Colors.white70),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${album.photoCount}장',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white70),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.people_outline,
                                              size: 12, color: Colors.white70),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${album.memberCount}명',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.main : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.main : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({required this.categories});
  final List<String> categories;

  static const _gradients = {
    '결혼': [Color(0xFFc0392b), Color(0xFFe84393)],
    '여행': [Color(0xFF1a5276), Color(0xFF2e86c1)],
    '모임': [Color(0xFF6c3483), Color(0xFFa569bd)],
    '생일': [Color(0xFF784212), Color(0xFFd4ac0d)],
    '기념일': [Color(0xFF0e6655), Color(0xFF1abc9c)],
    '연인': [Color(0xFFc0392b), Color(0xFFf1948a)],
    '반려동물': [Color(0xFF6e2f1a), Color(0xFFe59866)],
    '취미': [Color(0xFF935116), Color(0xFFf0b27a)],
    '일상': [Color(0xFF616a6b), Color(0xFF99a3a4)],
    '기록': [Color(0xFF1b2631), Color(0xFF5d6d7e)],
    '친구': [Color(0xFF0e6655), Color(0xFF52be80)],
    '독서': [Color(0xFF784212), Color(0xFFdc7633)],
    '공부': [Color(0xFF0e6251), Color(0xFF45b39d)],
  };

  @override
  Widget build(BuildContext context) {
    final key = categories.isNotEmpty ? categories.first : '기타';
    final colors = _gradients[key] ??
        [const Color(0xFF616a6b), const Color(0xFF99a3a4)];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
}