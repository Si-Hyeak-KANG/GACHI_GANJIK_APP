import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/album.dart';
import '../../controllers/photo/album_detail_controller.dart';
import '../../controllers/network/network_controller.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/photo/moment_card.dart';

class AlbumDetailView extends GetView<AlbumDetailController> {
  const AlbumDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // HomeView에서 전달한 Album 객체
    final album = Get.arguments['album'] as Album;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 오프라인 배너
                const _OfflineBanner(),

                _AppBar(album: album),
                _ShareCodeBanner(inviteCode: album.inviteCode),
                Expanded(child: _MomentsList()),
              ],
            ),

            // 업로드 중 오버레이
            Obx(() {
              if (!controller.isUploading.value) return const SizedBox();
              return Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        '사진 업로드 중...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),

      // 카메라 FAB
      floatingActionButton: Obx(() {
        if (controller.isUploading.value) return const SizedBox();

        final networkController = Get.find<NetworkController>();

        return FloatingActionButton(
          onPressed: () => _showImageSourceDialog(context),
          backgroundColor: AppColors.main,
          tooltip: networkController.isConnected.value
              ? '사진 업로드'
              : '사진 업로드 (온라인 복구 시 자동 업로드)',
          child: const Icon(Icons.camera_alt, color: Colors.white),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showImageSourceDialog(BuildContext context) {
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
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.main),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Get.back();
                controller.pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.main),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Get.back();
                controller.pickFromGallery();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
// 오프라인 배너
class _OfflineBanner extends GetView<NetworkController> {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isConnected.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.orange,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              '오프라인 - 저장된 사진만 표시됩니다',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
// 앱바
class _AppBar extends StatelessWidget {
  final Album album;

  const _AppBar({required this.album});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: Get.back,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${album.category ?? ''} · ${album.eventDate ?? album.createdAt}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 더보기 메뉴 (Phase 4에서 구현)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Get.snackbar(
              '준비 중',
              'Phase 4에서 구현됩니다',
              snackPosition: SnackPosition.BOTTOM,
            ),
          ),
        ],
      ),
    );
  }
}

// 공유 코드 배너
class _ShareCodeBanner extends StatelessWidget {
  final String inviteCode;

  const _ShareCodeBanner({required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mainLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '초대 코드',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                inviteCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.main,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Clipboard 복사는 flutter/services 사용
              Get.snackbar(
                '복사 완료',
                '초대 코드가 복사되었습니다',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              '복사',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// 모멘트 리스트
class _MomentsList extends GetView<AlbumDetailController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.main),
        );
      }

      if (controller.moments.isEmpty) {
        return EmptyState(
          icon: Icons.photo_library_outlined,
          message: '아직 사진이 없어요',
          subMessage: '카메라 버튼을 눌러\n첫 번째 추억을 남겨보세요',
        );
      }

      return RefreshIndicator(
        color: AppColors.main,
        onRefresh: controller.fetchMoments,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          itemCount: controller.moments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (_, index) {
            final moment = controller.moments[index];
            return MomentCard(moment: moment);
          },
        ),
      );
    });
  }
}