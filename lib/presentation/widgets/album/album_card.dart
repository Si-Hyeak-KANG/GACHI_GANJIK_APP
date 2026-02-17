import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/album.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  const AlbumCard({
    super.key,
    required this.album,
    required this.onTap,
  });

  // 카테고리별 배경 그라디언트
  // 왜 카테고리별로 다른 색상?
  // → 커버 이미지가 없을 때도 시각적으로 구분 가능
  static const _categoryGradients = {
    '결혼식': [Color(0xFFFFF4F5), Color(0xFFFFE4E8)],
    '여행': [Color(0xFFF0F8FF), Color(0xFFDCF0FF)],
    '모임': [Color(0xFFF5F0FF), Color(0xFFE8DCFF)],
    '생일': [Color(0xFFFFFBF0), Color(0xFFFFEFD0)],
    '기념일': [Color(0xFFF0FFF5), Color(0xFFDCFFEA)],
    '기타': [Color(0xFFFAFAFA), Color(0xFFF0F0F0)],
  };

  List<Color> get _gradientColors {
    final key = album.category ?? '기타';
    return _categoryGradients[key] ?? _categoryGradients['기타']!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커버 영역
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradientColors,
                  ),
                ),
                child: Stack(
                  children: [
                    // 커버 이미지 placeholder
                    const Center(
                      child: Icon(
                        Icons.photo_album_rounded,
                        size: 48,
                        color: AppColors.main,
                      ),
                    ),
                    // 카테고리 뱃지
                    if (album.category != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.main,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            album.category!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 정보 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        album.eventDate ?? album.createdAt,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.photo_outlined,
                            label: '사진 ${album.photoCount}',
                          ),
                          const SizedBox(width: 10),
                          _InfoChip(
                            icon: Icons.people_outline,
                            label: '참여 ${album.memberCount}명',
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
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}