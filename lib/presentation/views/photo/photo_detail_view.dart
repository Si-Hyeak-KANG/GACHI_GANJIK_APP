import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/photo/photo_detail_controller.dart';

class PhotoDetailView extends GetView<PhotoDetailController> {
  const PhotoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() => Stack(
          children: [
            // ✅ 수정: 사진 영역 (전체 화면)
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.photos.length,
              itemBuilder: (context, index) {
                final photo = controller.photos[index];
                return _PhotoViewer(imageUrl: photo.imageUrl);
              },
            ),

            // ✅ 수정: AppBar (오버레이)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _AppBar(),
            ),

            // 닫힌 상태: 하단 오버레이
            if (!controller.isModalExpanded.value)
              _CompactInfoOverlay(),

            // 열린 상태: 확장 모달
            if (controller.isModalExpanded.value)
              _ExpandedInfoSheet(),
          ],
        )),
      ),
    );
  }
}

// ✅ 수정: 앱바 (투명 배경 그라디언트)
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
            Colors.black.withOpacity(0.5),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// 사진 뷰어
class _PhotoViewer extends StatelessWidget {
  final String imageUrl;

  const _PhotoViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (_, __, ___) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 64,
          ),
        ),
      ),
    );
  }
}

// ✅ 수정: 닫힌 상태 오버레이
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
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 업로더 & 날짜
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    controller.currentPhoto.uploader[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentPhoto.uploader,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        controller.currentPhoto.dateOnly,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 메시지 (1줄 + 더보기)
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
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ✅ 수정: 아이콘 버튼들
            Row(
              children: [
                // 좋아요
                Obx(() => _OutlinedIconButton(
                  icon: controller.isLiked.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: controller.likeCount.value.toString(),
                  filled: controller.isLiked.value,
                  onTap: controller.toggleLike,
                )),

                const SizedBox(width: 16),

                // 댓글 (모달 열기)
                _OutlinedIconButton(
                  icon: Icons.chat_bubble_outline,
                  label: controller.currentPhoto.comments.length.toString(),
                  onTap: controller.expandModal,
                ),

                const SizedBox(width: 16),

                // 다운로드 (관리자만)
                if (controller.canDownload)
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
        ),
      ),
    );
  }
}

// ✅ 수정: 테두리만 흰색 아이콘 버튼
class _OutlinedIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  final bool isLoading;

  const _OutlinedIconButton({
    required this.icon,
    required this.label,
    this.filled = false,
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
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
          color: filled ? Colors.white : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: filled ? Colors.black : Colors.white,
                strokeWidth: 2,
              ),
            )
                : Icon(
              icon,
              size: 18,
              color: filled ? Colors.red : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: filled ? Colors.black : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 열린 상태 모달
class _ExpandedInfoSheet extends GetView<PhotoDetailController> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            // 아래로 드래그 시 닫기
            if (details.primaryDelta! > 10) {
              controller.collapseModal();
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // 핸들바
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inactive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // 사진 정보
                _PhotoInfo(),

                const Divider(height: 1),

                // 댓글 섹션
                Expanded(child: _CommentSection(scrollController)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 사진 정보 (업로더, 메시지, 액션)
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
            // 업로더 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mainLight,
                  child: Text(
                    photo.uploader[0],
                    style: const TextStyle(
                      color: AppColors.main,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.uploader,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        photo.uploadedAt,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 액션 버튼들
                Row(
                  children: [
                    // 좋아요
                    _ActionButton(
                      icon: controller.isLiked.value
                          ? Icons.favorite
                          : Icons.favorite_border,
                      label: controller.likeCount.value.toString(),
                      color: controller.isLiked.value
                          ? Colors.red
                          : AppColors.textSecondary,
                      onTap: controller.toggleLike,
                    ),

                    // 다운로드 (관리자만)
                    if (controller.canDownload) ...[
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.file_download_outlined,
                        label: '저장',
                        onTap: controller.isSavingImage.value
                            ? null
                            : controller.saveImage,
                        isLoading: controller.isSavingImage.value,
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // 메시지
            if (photo.message != null && photo.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                photo.message!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
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
  final Color? color;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
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
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: color ?? AppColors.textSecondary,
                strokeWidth: 2,
              ),
            )
                : Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color ?? AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 댓글 섹션
class _CommentSection extends GetView<PhotoDetailController> {
  final ScrollController scrollController;

  const _CommentSection(this.scrollController);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 댓글 리스트
        Expanded(
          child: Obx(() {
            if (controller.isLoadingComments.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.main),
              );
            }

            if (controller.comments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: AppColors.inactive,
                    ),
                    SizedBox(height: 12),
                    Text(
                      '첫 댓글을 남겨보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: controller.comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final comment = controller.comments[index];
                final isMine = comment.user == '나';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isMine
                          ? AppColors.mainLight
                          : AppColors.cardBg,
                      child: Text(
                        comment.user[0],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isMine
                              ? AppColors.main
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.user,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            comment.text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isMine)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => controller.deleteComment(index),
                      ),
                  ],
                );
              },
            );
          }),
        ),

        // 댓글 입력
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  decoration: InputDecoration(
                    hintText: '댓글을 남겨보세요',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.inactive,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => controller.addComment(),
                ),
              ),
              const SizedBox(width: 10),
              Obx(() => GestureDetector(
                onTap: controller.isAddingComment.value
                    ? null
                    : controller.addComment,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: controller.commentController.text.isEmpty
                        ? AppColors.inactive
                        : AppColors.main,
                    shape: BoxShape.circle,
                  ),
                  child: controller.isAddingComment.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}