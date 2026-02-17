import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/album/album_list_controller.dart';
import '../../widgets/album/album_card.dart';
import '../../widgets/common/empty_state.dart';

class HomeView extends GetView<AlbumListController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _HomeAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main),
                  );
                }

                if (controller.albums.isEmpty) {
                  return EmptyState(
                    icon: Icons.photo_album_outlined,
                    message: '아직 사진첩이 없어요',
                    subMessage: '새 사진첩을 만들거나\n초대 코드로 입장해보세요',
                    buttonLabel: '사진첩 만들기',
                    onButtonTap: () => Get.toNamed(Routes.createAlbum),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.main,
                  onRefresh: controller.fetchAlbums,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                    itemCount: controller.albums.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final album = controller.albums[index];
                      return AlbumCard(
                        album: album,
                        onTap: () {
                          // Phase 3에서 구현
                          Get.snackbar(
                            album.title,
                            'Phase 3에서 앨범 상세 화면이 구현됩니다',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// 앱 바를 별도 위젯으로 분리
// 왜 분리? → HomeView 빌드 최적화, 재사용 가능
class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 타이틀
          Row(
            children: [
              Container(
                width: 32,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.mainLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_album_rounded,
                  size: 18,
                  color: AppColors.main,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '같이간직',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // 액션 버튼들
          Row(
            children: [
              // 입장 버튼
              _ActionButton(
                label: '입장',
                icon: Icons.qr_code_rounded,
                onTap: () => _showJoinBottomSheet(context),
                isOutlined: true,
              ),
              const SizedBox(width: 8),
              // 만들기 버튼
              _ActionButton(
                label: '만들기',
                icon: Icons.add,
                onTap: () => Get.toNamed(Routes.createAlbum),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showJoinBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _JoinAlbumBottomSheet(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isOutlined ? AppColors.mainLight : AppColors.main,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isOutlined ? AppColors.main : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isOutlined ? AppColors.main : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 앨범 입장 바텀 시트
class _JoinAlbumBottomSheet extends StatefulWidget {
  const _JoinAlbumBottomSheet();

  @override
  State<_JoinAlbumBottomSheet> createState() => _JoinAlbumBottomSheetState();
}

class _JoinAlbumBottomSheetState extends State<_JoinAlbumBottomSheet> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlbumListController>();

    return Padding(
      // 키보드 올라올 때 바텀 시트도 올라옴
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들바
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inactive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              '사진첩 입장',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '초대 코드를 입력하거나 QR을 스캔해주세요',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // 코드 입력
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '예) WD2025A',
                hintStyle: const TextStyle(
                  color: AppColors.inactive,
                  fontSize: 15,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: AppColors.cardBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.main,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 입장 버튼
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isJoining.value
                    ? null
                    : () => controller.joinAlbum(_codeController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                  disabledBackgroundColor: AppColors.inactive,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: controller.isJoining.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  '입장하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
            const SizedBox(height: 12),

            // QR 스캔 버튼 (Phase 3 이후 구현)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.snackbar(
                  '준비 중',
                  'QR 스캔은 Phase 3에서 구현됩니다',
                  snackPosition: SnackPosition.BOTTOM,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainLight,
                  foregroundColor: AppColors.main,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'QR코드 스캔',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}