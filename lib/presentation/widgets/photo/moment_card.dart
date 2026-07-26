import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/entities/album.dart';
import '../common/smart_image.dart';

/// 추억 피드 카드 (업로드 배치 단위)
/// 상단: 한줄 추억 코멘트 → 사진 가로 스크롤 → 하단: 업로더 + 우측 업로드 날짜
class MomentCard extends StatelessWidget {
  final Moment moment;
  final Album album;

  const MomentCard({super.key, required this.moment, required this.album});

  @override
  Widget build(BuildContext context) {
    final comment = moment.comment;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -16,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 상단: 한줄 추억 코멘트 ──
          if (comment != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Text(
                comment,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),

          // ── 사진 가로 스크롤 ──
          _PhotoStrip(moment: moment, album: album),

          // ── 하단: 업로더 + 우측 하단 업로드 날짜 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                _UploaderAvatar(
                  profileUrl: moment.uploaderProfileImageUrl,
                  initial: moment.uploaderInitial,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    moment.uploaderNickname.isNotEmpty
                        ? moment.uploaderNickname
                        : '알 수 없음',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  moment.uploadedDateDisplay,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 사진 가로 스크롤 (1장이면 꽉 차게, 여러 장이면 스크롤)
// ─────────────────────────────────────────
class _PhotoStrip extends StatelessWidget {
  final Moment moment;
  final Album album;

  const _PhotoStrip({required this.moment, required this.album});

  static const double _height = 260;
  static const double _itemWidth = 200;

  @override
  Widget build(BuildContext context) {
    final photos = moment.photos;
    if (photos.isEmpty) return const SizedBox.shrink();

    if (photos.length == 1) {
      final photo = photos.first;
      return GestureDetector(
        onTap: () => _openDetail(0),
        child: Hero(
          tag: 'photo_hero_${photo.id}',
          child: SizedBox(
            height: _height,
            width: double.infinity,
            child: SmartImage(imageUrl: photo.imageUrl, fit: BoxFit.cover),
          ),
        ),
      );
    }

    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final photo = photos[i];
          return GestureDetector(
            onTap: () => _openDetail(i),
            child: Hero(
              tag: 'photo_hero_${photo.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: _itemWidth,
                  height: _height,
                  child: SmartImage(imageUrl: photo.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openDetail(int index) {
    Get.toNamed(
      Routes.photoDetail,
      arguments: {
        'photos': moment.photos,
        'initialIndex': index,
        'album': album,
      },
    );
  }
}

// ─────────────────────────────────────────
// 업로더 아바타 (프로필 사진 우선, 없으면 이니셜)
// ─────────────────────────────────────────
class _UploaderAvatar extends StatelessWidget {
  final String? profileUrl;
  final String initial;

  const _UploaderAvatar({required this.profileUrl, required this.initial});

  static const double _size = 28;

  @override
  Widget build(BuildContext context) {
    final hasProfile = profileUrl != null && profileUrl!.isNotEmpty;
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.main,
        shape: BoxShape.circle,
      ),
      child: hasProfile
          ? Image.network(
        profileUrl!,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialText(),
      )
          : _initialText(),
    );
  }

  Widget _initialText() => Text(
    initial,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );
}