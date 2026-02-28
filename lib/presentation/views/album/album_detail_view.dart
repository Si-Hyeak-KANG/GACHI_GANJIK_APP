import 'package:flutter/material.dart';
import 'package:gachiganjik_app/presentation/widgets/album/album_menu_sheet.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/album.dart';
import '../../controllers/album/album_detail_controller.dart';
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
                const _OfflineBanner(),
                _CoverSection(album: album),
                Expanded(child: _MomentsList(album: album)),
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

class _CoverSection extends StatelessWidget {
  final Album album;

  const _CoverSection({required this.album});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 커버 이미지 또는 그라디언트 배경
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getCoverGradient(),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // AppBar 공간 확보

              // 앨범 아이콘
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_album_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // 앨범 제목
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  album.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // 카테고리 & 날짜
              Text(
                '${album.categoriesDisplay} · ${album.eventDateDisplay}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // AppBar (투명 배경)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  color: Colors.white,
                  onPressed: Get.back,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: Colors.white,
                  onPressed: () => _showAlbumMenu(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 카테고리별 커버 그라디언트
  List<Color> _getCoverGradient() {
    const gradients = {
      '결혼': [Color(0xFFFF6F7D), Color(0xFFFF9A9E)],
      '여행': [Color(0xFF4facfe), Color(0xFF00f2fe)],
      '모임': [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
      '생일': [Color(0xFFffecd2), Color(0xFFfcb69f)],
      '기념일': [Color(0xFF89f7fe), Color(0xFF66a6ff)],
      '연인': [Color(0xFFff9a9e), Color(0xFFfecfef)],
      '반려동물': [Color(0xFFffeaa7), Color(0xFFfdcb6e)],
      '취미': [Color(0xFFffa502), Color(0xFFff6348)],
      '일상': [Color(0xFFdfe6e9), Color(0xFFb2bec3)],
      '기록': [Color(0xFF6c5ce7), Color(0xFFa29bfe)],
      '친구': [Color(0xFF00b894), Color(0xFF55efc4)],
      '독서': [Color(0xFFe17055), Color(0xFFfdcb6e)],
      '공부': [Color(0xFF00cec9), Color(0xFF81ecec)],
    };

    final firstCategory = album.categories.isNotEmpty
        ? album.categories.first
        : '기타';

    return gradients[firstCategory] ?? [
      const Color(0xFFbdc3c7),
      const Color(0xFF95a5a6),
    ];
  }

  void _showAlbumMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AlbumMenuSheet(album: album),
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

// 모멘트 리스트
class _MomentsList extends GetView<AlbumDetailController> {
  final Album album;

  const _MomentsList({required this.album});

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
            return MomentCard(
              moment: moment,
              album: album,
            );
          },
        ),
      );
    });
  }
}