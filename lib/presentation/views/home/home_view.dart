import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/sources/firebase/firebase_storage_source.dart';
import '../../../data/sources/remote/mock/mock_user_remote_source.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../controllers/album/album_list_controller.dart';
import '../../controllers/network/network_controller.dart';
import '../../controllers/settings/settings_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../../widgets/album/album_action_sheet.dart';
import '../../widgets/common/empty_state.dart';
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
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () => _showActionSheet(context),
        backgroundColor: AppColors.main,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
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
            label: '앨범',
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

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => const AlbumActionSheet(),
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
        Get.lazyPut(() => UserController(userRepository: Get.find()),
            fenix: true);
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

// ─────────────────────────────────────────────────────────────
// 오프라인 배너
// ─────────────────────────────────────────────────────────────

class _OfflineBanner extends GetView<NetworkController> {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isConnected.value) return const SizedBox.shrink();
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
              '오프라인 모드',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// 앨범 목록 화면
// ─────────────────────────────────────────────────────────────

class _AlbumListScreen extends GetView<AlbumListController> {
  const _AlbumListScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
            child: Row(
              children: [
                Text(
                  'MOWA',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: AppColors.main,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search_rounded,
                      color: AppColors.textPrimary, size: 24),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.textPrimary, size: 24),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.main));
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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    // 앨범 코드로 참여하기
                    _JoinButton(),
                    const SizedBox(height: 36),

                    // 카테고리 섹션
                    _CategorySection(albums: controller.albums),
                    const SizedBox(height: 36),

                    // 최근 활동한 앨범
                    const _RecentAlbumsSection(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 앨범 코드로 참여하기 버튼
// ─────────────────────────────────────────────────────────────

class _JoinButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.guestEntry),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.qr_code_rounded,
                size: 20, color: AppColors.main),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '앨범 코드로 참여하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 카테고리 섹션
// ─────────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.albums});
  final List<Album> albums;

  /// 카테고리별로 그룹핑 — {카테고리: [Album, ...]}
  Map<String, List<Album>> get _grouped {
    final map = <String, List<Album>>{};
    for (final album in albums) {
      for (final cat in album.categories) {
        map.putIfAbsent(cat, () => []).add(album);
      }
    }
    // 앨범 수 내림차순 정렬
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length)),
    );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    if (grouped.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            Text(
              '카테고리',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 4),

            Text(
              '주제별 앨범을 둘러보세요',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: grouped.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final category = grouped.keys.elementAt(index);
              final catAlbums = grouped[category]!;
              // 썸네일: coverImageUrl 있는 것 우선, 없으면 첫 번째
              final thumb = catAlbums.firstWhere(
                    (a) =>
                a.coverImageUrl != null &&
                    a.coverImageUrl!.trim().isNotEmpty,
                orElse: () => catAlbums.first,
              );

              return GestureDetector(
                onTap: () => Get.toNamed(
                  Routes.categoryAlbumList,
                  arguments: {
                    'category': category,
                    'albums': catAlbums,
                  },
                ),
                child: _CategoryCard(
                  category: category,
                  count: catAlbums.length,
                  thumbUrl: thumb.coverImageUrl,
                  categories: thumb.categories,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.thumbUrl,
    required this.categories,
  });

  final String category;
  final int count;
  final String? thumbUrl;
  final List<String> categories;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        color: AppColors.cardBg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [

          if (thumbUrl != null && thumbUrl!.trim().isNotEmpty)
            Image.network(
              thumbUrl!,
              fit: BoxFit.cover,
            )
          else
            Container(
              color: const Color(0xFFF4F5F7),
              child: const Center(
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: Color(0xFFB7BEC8),
                ),
              ),
            ),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x99000000),
                ],
                stops: [
                  0.45,
                  1,
                ],
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height:4),

                Text(
                  '$count개의 앨범',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize:13,
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

// ─────────────────────────────────────────────────────────────
// 최근 활동한 앨범 섹션
// ─────────────────────────────────────────────────────────────

class _RecentAlbumsSection extends GetView<AlbumListController> {
  const _RecentAlbumsSection();

  List<Album> _sorted(List<Album> albums) {
    final list = List<Album>.from(albums);
    list.sort((a, b) {
      final aTime = a.lastPhotoUploadedAt ?? a.createdAt;
      final bTime = b.lastPhotoUploadedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 활동한 앨범',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          final sorted = _sorted(controller.albums);
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final album = sorted[index];
              return _RecentAlbumCard(album: album);
            },
          );
        }),
      ],
    );
  }
}

class _RecentAlbumCard extends StatelessWidget {
  const _RecentAlbumCard({required this.album});
  final Album album;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    final weeks = (diff.inDays / 7).floor();
    return '${weeks}주 전';
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _timeAgo(album.lastPhotoUploadedAt ?? album.updatedAt);

    return Obx(() {
      final hasUpdate = Get.isRegistered<AlbumListController>()
          ? Get.find<AlbumListController>().updatedAlbumIds.contains(album.id)
          : false;

      return GestureDetector(
        onTap: () {
          if (Get.isRegistered<AlbumListController>()) {
            Get.find<AlbumListController>().clearBadge(album.id);
          }
          Get.toNamed(
            Routes.albumDetail,
            arguments: {'album': album, 'albumId': album.id},
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: hasUpdate
                ? [
              BoxShadow(
                color: AppColors.main.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              )
            ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (album.coverImageUrl != null &&
                  album.coverImageUrl!.trim().isNotEmpty)
                Image.network(
                  album.coverImageUrl!.trim(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: Color(0xFFB6BCC6),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  color: const Color(0xFFF3F4F6),
                  child: const Center(
                    child: Icon(
                      Icons.photo_library_outlined,
                      size: 48,
                      color: Color(0xFFB6BCC6),
                    ),
                  ),
                ),

              // 딤
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x99000000)],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),

              // 뱃지
              if (hasUpdate)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.main,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.main, width: 1.5),
                    ),
                  ),
                ),

              // 텍스트
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      album.title,
                      style: const TextStyle(
                        fontSize: 16,
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
                            timeAgo.isNotEmpty
                                ? '$timeAgo · 사진 ${album.photoCount}장'
                                : '사진 ${album.photoCount}장',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.people_outline,
                                size: 13, color: Colors.white70),
                            const SizedBox(width: 3),
                            Text(
                              '${album.memberCount}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
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
    }); // Obx
  }
}