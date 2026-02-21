import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/sources/firebase/firebase_storage_source.dart';
import '../../../data/sources/remote/mock/mock_user_remote_source.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../controllers/album/album_list_controller.dart';
import '../../controllers/network/network_controller.dart';
import '../../controllers/settings/settings_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../../widgets/album/album_card.dart';
import '../../widgets/common/empty_state.dart';
import '../qr/qr_scan_view.dart';
import '../user/mypage_view.dart';
import '../settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _AlbumListScreen(),
    const MyPageView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    _initializeControllers();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const _OfflineBanner(),

          // 기존 화면
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.main,
        unselectedItemColor: AppColors.inactive,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album_outlined),
            activeIcon: Icon(Icons.photo_album),
            label: '사진첩',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이페이지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }

  void _initializeControllers() {
    if (_currentIndex == 1) {
      if (!Get.isRegistered<UserRepository>()) {
        Get.lazyPut<UserRepository>(
              () => UserRepositoryImpl(
            remoteSource: MockUserRemoteSource(),
            storageSource: FirebaseStorageSource(),
          ),
          fenix: true,
        );
      }

      if (!Get.isRegistered<UserController>()) {
        Get.lazyPut(
              () => UserController(userRepository: Get.find()),
          fenix: true,
        );
      }
    } else if (_currentIndex == 2) {
      if (!Get.isRegistered<UserRepository>()) {
        Get.lazyPut<UserRepository>(
              () => UserRepositoryImpl(
            remoteSource: MockUserRemoteSource(),
            storageSource: FirebaseStorageSource(),
          ),
          fenix: true,
        );
      }

      if (!Get.isRegistered<SettingsController>()) {
        Get.lazyPut(
              () => SettingsController(
            userRepository: Get.find(),
            localStorage: Get.find(),
          ),
          fenix: true,
        );
      }
    }
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text(
              '오프라인 모드',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AlbumListScreen extends GetView<AlbumListController> {
  const _AlbumListScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              children: [
                const Icon(Icons.photo_album, color: AppColors.main, size: 28),
                const SizedBox(width: 8),
                const Text(
                  '같이간직',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // 입장 버튼
                ElevatedButton.icon(
                  onPressed: () => _showJoinDialog(context),
                  icon: const Icon(Icons.qr_code_scanner, size: 16),
                  label: const Text('입장'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainLight,
                    foregroundColor: AppColors.main,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.createAlbum),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('만들기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),

          // Album List
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
                  message: '아직 앨범이 없어요',
                  subMessage: '새로운 앨범을 만들어\n추억을 함께 저장해보세요',
                  buttonLabel: '앨범 만들기',
                  onButtonTap: () => Get.toNamed(Routes.createAlbum),
                );
              }

              return RefreshIndicator(
                color: AppColors.main,
                onRefresh: controller.fetchAlbums,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  itemCount: controller.albums.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    final album = controller.albums[index];
                    return AlbumCard(
                      album: album,
                      onTap: () {
                        Get.toNamed(
                          Routes.albumDetail,
                          arguments: {
                            'album': album,
                            'albumId': album.id,
                          },
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
    );
  }

  void _showJoinDialog(BuildContext context) {
    final codeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: '초대 코드 입력 (예: WD2025A)',
                hintStyle: const TextStyle(color: AppColors.inactive),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final code = codeController.text.trim();
                  if (code.isEmpty) {
                    Get.snackbar(
                      '알림',
                      '초대 코드를 입력해주세요',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  Get.back();
                  Get.find<AlbumListController>().joinAlbum(code);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '입장하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // QR 스캔 화면으로 이동
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.to(() => const QRScanView());
                },
                icon: const Icon(Icons.qr_code_scanner, size: 20),
                label: const Text(
                  'QR코드 스캔',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.main,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.main),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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