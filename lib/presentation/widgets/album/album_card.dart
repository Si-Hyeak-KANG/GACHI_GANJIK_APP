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

  static const _categoryGradients = {
    '결혼': [Color(0xFFFFF4F5), Color(0xFFFFE4E8)],      // 핑크/로즈
    '여행': [Color(0xFFF0F8FF), Color(0xFFDCF0FF)],      // 블루/하늘
    '모임': [Color(0xFFF5F0FF), Color(0xFFE8DCFF)],      // 보라/퍼플
    '생일': [Color(0xFFFFFBF0), Color(0xFFFFEFD0)],      // 노랑/골드
    '기념일': [Color(0xFFF0FFF5), Color(0xFFDCFFEA)],    // 민트/그린
    '연인': [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],      // 레드/핑크
    '반려동물': [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],  // 베이지/브라운
    '취미': [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],      // 오렌지
    '일상': [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],      // 회색/무채색
    '기록': [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],      // 네이비/인디고
    '친구': [Color(0xFFF1F8E9), Color(0xFFDCEDC8)],      // 연두/라임
    '독서': [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],      // 카키/올리브
    '공부': [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],      // 청록/틸
    '기타': [Color(0xFFFAFAFA), Color(0xFFF0F0F0)],      // 회색
  };

  List<Color> get _gradientColors {
    final key = album.categories.isNotEmpty ? album.categories.first : '기타';
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  fit: StackFit.expand,
                  children: [
                    // coverImageUrl이 있을 경우 → 네트워크 이미지
                    if (album.coverImageUrl != null &&
                        album.coverImageUrl!.trim().isNotEmpty)
                      Image.network(
                        album.coverImageUrl!.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            width: 48,
                            height: 48,
                            child: Image.asset(
                              'assets/icons/album_icon.png',
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      )
                    else
                    // 없을 경우 → 나만의 기본 앨범 이미지
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.asset(
                          'assets/icons/album_icon.png',
                          fit: BoxFit.contain,
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
                      // ✅ 수정: eventDateDisplay 사용
                      Expanded(
                        child: Text(
                          album.eventDateDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
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