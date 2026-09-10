import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/photo/photo_detail_controller.dart';
import '../../widgets/common/smart_image.dart';

class PhotoDetailView extends GetView<PhotoDetailController> {
  const PhotoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() => Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.photos.length,
              itemBuilder: (context, index) {
                final photo = controller.photos[index];
                final isInitial = index == controller.initialIndex;
                return _PhotoViewer(
                  imageUrl: photo.imageUrl,
                  heroTag: isInitial ? 'photo_hero_${photo.id}' : null,
                );
              },
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _AppBar(),
            ),

            if (!controller.isModalExpanded.value)
              _CompactInfoOverlay(),

            if (controller.isModalExpanded.value)
              _ExpandedInfoSheet(),
          ],
        )),
      ),
    );
  }
}

class _AppBar extends GetView<PhotoDetailController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: Get.back,
          ),
          Obx(() => Text(
            '${controller.currentIndex.value + 1} / ${controller.photos.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          )),
          // 본인 사진이거나 OWNER/ADMIN이면 더보기 메뉴 표시
          Obx(() => controller.canDeletePhoto
              ? IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showPhotoMenu(context),
          )
              : const SizedBox(width: 48)),
        ],
      ),
    );
  }

  void _showPhotoMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 메시지 수정 — 본인만
            if (controller.isPhotoOwner)
              ListTile(
                leading: const Icon(Icons.edit_outlined,
                    color: AppColors.textPrimary),
                title: const Text('메시지 수정'),
                onTap: () {
                  Get.back();
                  controller.updateMessage();
                },
              ),
            // 삭제 — 본인 또는 OWNER/ADMIN
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('사진 삭제',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                controller.deletePhoto();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const _PhotoViewer({required this.imageUrl, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final image = SmartImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
    );

    if (heroTag == null) {
      return Center(child: image);
    }

    return Center(
      child: Hero(
        tag: heroTag!,
        child: image,
      ),
    );
  }
}

class _CompactInfoOverlay extends GetView<PhotoDetailController> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _ProfileAvatar(
                  profileUrl: controller.currentPhoto.uploaderProfileImageUrl,
                  initial: controller.currentPhoto.uploaderInitial,
                  radius: 16,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  textColor: Colors.white,
                  fontSize: 13,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentPhoto.uploaderNickname,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        controller.currentPhoto.photoDateDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (controller.currentPhoto.message != null &&
                controller.currentPhoto.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: controller.expandModal,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentPhoto.message!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '더보기',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (controller.canDownload) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Obx(() => _OutlinedIconButton(
                    icon: Icons.file_download_outlined,
                    label: '저장',
                    onTap: controller.isSavingImage.value
                        ? null
                        : controller.saveImage,
                    isLoading: controller.isSavingImage.value,
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutlinedIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _OutlinedIconButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedInfoSheet extends GetView<PhotoDetailController> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.25,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! > 10) controller.collapseModal();
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.inactive,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  _PhotoInfo(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhotoInfo extends GetView<PhotoDetailController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final photo = controller.currentPhoto;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ProfileAvatar(
                  profileUrl: photo.uploaderProfileImageUrl,
                  initial: photo.uploaderInitial,
                  radius: 18,
                  backgroundColor: AppColors.mainLight,
                  textColor: AppColors.main,
                  fontSize: 14,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(photo.uploaderNickname,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(photo.uploadedAtDisplay,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (controller.canDownload)
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.file_download_outlined,
                        label: '저장',
                        onTap: controller.isSavingImage.value
                            ? null
                            : controller.saveImage,
                        isLoading: controller.isSavingImage.value,
                      ),
                    ],
                  ),
              ],
            ),
            if (photo.message != null && photo.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(photo.message!,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4)),
            ],
          ],
        ),
      );
    });
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            isLoading
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: AppColors.textSecondary,
                    strokeWidth: 2))
                : Icon(icon, size: 20,
                color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 프로필 아바타 (프로필 이미지 우선, 없으면 닉네임 첫 글자)
// ─────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  final String? profileUrl;
  final String initial;
  final double radius;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const _ProfileAvatar({
    required this.profileUrl,
    required this.initial,
    required this.radius,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = profileUrl != null && profileUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: hasUrl ? CachedNetworkImageProvider(profileUrl!) : null,
      child: hasUrl
          ? null
          : Text(
        initial,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}