import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/entities/photo.dart';
import '../../controllers/album/album_detail_controller.dart';
import '../../controllers/network/network_controller.dart';
import '../../widgets/album/album_menu_sheet.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/photo/moment_card.dart';
import '../../widgets/common/smart_image.dart';
import '../album/participant_bottom_sheet.dart';

enum AlbumViewMode { memory, grid, date }

class _P {
  static const ink = AppColors.textPrimary;
  static const sub = AppColors.textSecondary;
  static const accent = AppColors.main;
  static const accentSoft = AppColors.mainSoft;
  static const track = AppColors.surfaceSecondary;
  static const card = AppColors.cardBg;
  static const line = AppColors.border;
  static const shadow = AppColors.shadow;
}

// ─────────────────────────────────────────
// 메인 뷰
// ─────────────────────────────────────────
class AlbumDetailView extends GetView<AlbumDetailController> {
  const AlbumDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final album = Get.arguments['album'] as Album;
    final viewMode = AlbumViewMode.memory.obs;

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _AlbumBody(album: album, viewMode: viewMode),
          const Positioned(
            top: 0, left: 0, right: 0,
            child: _OfflineBanner(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 바디
// ─────────────────────────────────────────
class _AlbumBody extends GetView<AlbumDetailController> {
  final Album album;
  final Rx<AlbumViewMode> viewMode;

  const _AlbumBody({required this.album, required this.viewMode});

  // Hero 높이 + Glass Card 겹침
  static const double _heroH = 356.0;
  static const double _cardH = 84.0; // GlassStatCard 높이
  static const double _overlap = 44.0; // Hero 아래로 겹치는 양

  @override
  Widget build(BuildContext context) {
    final sc = ScrollController();
    final appBarVisible = false.obs;

    sc.addListener(() {
      final show = sc.offset > 250;
      if (appBarVisible.value != show) appBarVisible.value = show;
    });

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.main,
          onRefresh: controller.fetchMoments,
          child: CustomScrollView(
            controller: sc,
            slivers: [
              // ── Hero + Glass Card 를 Stack으로 묶어 하나의 슬리버로 ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: _heroH + _cardH - _overlap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Hero 이미지
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: _heroH,
                        child: _HeroSection(album: album),
                      ),
                      // Glass Stat Card — Hero 하단에 겹쳐서 시작
                      Positioned(
                        bottom: 0,
                        left: 16,
                        right: 16,
                        child: _GlassStatCard(album: album),
                      ),
                    ],
                  ),
                ),
              ),

              // ── View Selector ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Obx(() => _ViewSelector(
                    current: viewMode.value,
                    onChanged: (m) => viewMode.value = m,
                  )),
                ),
              ),

              // ── Content ──
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                          child:
                          CircularProgressIndicator(color: AppColors.main)),
                    );
                  }
                  if (controller.moments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: EmptyState(
                        icon: Icons.photo_library_outlined,
                        message: '아직 사진이 없어요',
                        subMessage: '카메라 버튼을 눌러\n첫 번째 추억을 남겨보세요',
                      ),
                    );
                  }
                  return Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child:
                    _content(viewMode.value, controller.moments, album),
                  ));
                }),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),

        // ── Sticky AppBar (Blur) ──
        Obx(() => IgnorePointer(
          ignoring: !appBarVisible.value,
          child: AnimatedOpacity(
            opacity: appBarVisible.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: _StickyAppBar(album: album),
          ),
        )),
      ],
    );
  }

  Widget _content(AlbumViewMode mode, List<Moment> moments, Album album) {
    switch (mode) {
      case AlbumViewMode.grid:
        return _GridContent(
            key: const ValueKey('grid'), moments: moments, album: album);
      case AlbumViewMode.memory:
        return _MemoryContent(
            key: const ValueKey('memory'), moments: moments, album: album);
      case AlbumViewMode.date:
        return _DateContent(
            key: const ValueKey('date'), moments: moments, album: album);
    }
  }
}

// ─────────────────────────────────────────
// STICKY APPBAR
// ─────────────────────────────────────────
class _StickyAppBar extends StatelessWidget {
  final Album album;

  const _StickyAppBar({required this.album});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg.withOpacity(.92),
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(.06),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  _CircleBtn(
                      icon: Icons.arrow_back_ios_new,
                      onTap: Get.back,
                      hero: false),
                  Expanded(
                    child: Text(
                      album.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _P.ink,
                          letterSpacing: -0.2),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, color: _P.ink),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => AlbumMenuSheet(album: album),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 원형 버튼
// ─────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hero;

  const _CircleBtn({required this.icon, required this.onTap, this.hero = true});

  @override
  Widget build(BuildContext context) {
    Widget btn = Material(
      color: hero ? Colors.black.withOpacity(0.32) : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: Colors.white.withOpacity(0.2),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: hero ? Colors.white : _P.ink),
        ),
      ),
    );

    if (hero) {
      btn = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: btn,
        ),
      );
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8), child: btn);
  }
}

// ─────────────────────────────────────────
// HERO
// ─────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final Album album;

  const _HeroSection({required this.album});

  List<Color> _grad() {
    const g = {
      '결혼': [Color(0xFFFF6F7D), Color(0xFFFF9A9E)],
      '여행': [Color(0xFF6B4226), Color(0xFF9D7248)],
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
    final cat = album.categories.isNotEmpty ? album.categories.first : '';
    return g[cat] ?? [const Color(0xFF5C4033), const Color(0xFF8D6E63)];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 커버
        if (album.coverImageUrl != null &&
            album.coverImageUrl!.trim().isNotEmpty)
          Image.network(album.coverImageUrl!.trim(),
              fit: BoxFit.cover, errorBuilder: (_, __, ___) => _gradBox())
        else
          _gradBox(),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.08),
                Colors.black.withOpacity(.18),
                Colors.black.withOpacity(.72),
              ],
              stops: const [0.0, 0.38, 1.0],
            ),
          ),
        ),

        Positioned(
          left: 22,
          right: 22,
          bottom: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _MetaBadge(album: album),
              const SizedBox(height: 10),
              Text(
                album.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                  letterSpacing: -1,
                  shadows: [Shadow(color: Color(0x44000000), blurRadius: 16)],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // 뒤로가기 + 카메라 + 더보기
        Positioned(
          top: MediaQuery.of(context).padding.top + 4,
          left: 4,
          right: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleBtn(icon: Icons.arrow_back_ios_new, onTap: Get.back),
              Row(
                children: [
                  _CircleBtn(
                    icon: Icons.photo_camera_outlined,
                    onTap: () =>
                        Get.find<AlbumDetailController>().pickCoverImage(),
                  ),
                  _CircleBtn(
                    icon: Icons.more_horiz_rounded,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => AlbumMenuSheet(album: album),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gradBox() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _grad(),
      ),
    ),
  );
}

class _MetaBadge extends StatelessWidget {
  final Album album;

  const _MetaBadge({required this.album});

  @override
  Widget build(BuildContext context) {
    final cat = album.categories.isNotEmpty ? album.categories.first : null;
    final parts = [
      if (cat != null) cat,
      if (album.eventDateDisplay.isNotEmpty) album.eventDateDisplay,
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      child: Text(
        parts.join('  ·  '),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// GLASS STAT CARD
// ─────────────────────────────────────────
class _GlassStatCard extends StatelessWidget {
  final Album album;

  const _GlassStatCard({required this.album});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.92),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(.04),
              width: .8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 45,
                spreadRadius: -18,
                offset: Offset(0, 18),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: SizedBox(
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: GetX<AlbumDetailController>(
                      builder: (c) => _StatCell(
                        value:
                        '${c.moments.fold<int>(0, (s, m) => s + m.photos.length)}',
                        label: '사진',
                      ),
                    ),
                  ),
                ),
                _vLine(),
                Expanded(
                  child: Center(
                    child: GetX<AlbumDetailController>(
                      builder: (c) => _StatCell(
                        value: '${c.moments.length}',
                        label: '추억',
                      ),
                    ),
                  ),
                ),
                _vLine(),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => ParticipantBottomSheet.show(context, album),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          final c       = Get.find<AlbumDetailController>();
                          final members = c.members.toList(); // RxList → List (reactive 읽기)
                          return _MemberAvatarStack(members: members);
                        }),
                        const SizedBox(height: 4),
                        Text(
                          '참여자 ${album.memberCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _vLine() => Container(
    width: 1,
    height: 52,
    color: AppColors.divider,
  );
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: .95,
              letterSpacing: -0.6,
              color: _P.ink,
            )),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500,
                color: Color(0xff8E8E93))),
      ],
    );
  }
}

class _MemberAvatarStack extends StatelessWidget {
  final List<dynamic> members;

  const _MemberAvatarStack({required this.members});

  static const _fallbackColors = [
    Color(0xFFA8674E), Color(0xFF6B8E7C), Color(0xFF7B6E9A),
    Color(0xFF8E7B5A), Color(0xFF5A7B8E),
  ];

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox(height: 28, width: 28);

    final shown = members.length.clamp(0, 3);
    final extra = members.length - shown;
    const size  = 28.0;
    const step  = 18.0;

    final items = <Widget>[
      for (var i = 0; i < shown; i++) _avatar(members[i], i, size),
      if (extra > 0) _extraDot(extra, size),
    ];

    return SizedBox(
      height: size,
      width: size + (items.length - 1) * step,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(left: i * step, child: items[i]),
        ],
      ),
    );
  }

  Widget _avatar(dynamic member, int index, double size) {
    final profileUrl = member.profileImageUrl as String?;
    final nickname   = (member.nickname as String?) ?? '';
    final initial    = nickname.isNotEmpty ? nickname[0] : '?';
    final bg         = _fallbackColors[index % _fallbackColors.length];

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        color: bg,
      ),
      child: ClipOval(
        child: profileUrl != null && profileUrl.isNotEmpty
            ? Image.network(
          profileUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initial(initial),
        )
            : _initial(initial),
      ),
    );
  }

  Widget _extraDot(int extra, double size) => Container(
    width: size, height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _P.ink,
      border: Border.all(color: Colors.white, width: 1.5),
    ),
    child: Text(
      '+$extra',
      style: const TextStyle(
        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _initial(String ch) => Container(
    alignment: Alignment.center,
    child: Text(ch,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}

// ─────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final Album album;

  const _ActionButtons({required this.album});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Pill(
              icon: Icons.ios_share_outlined,
              label: '공유',
              filled: true,
              onTap: () {}),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Pill(
              icon: Icons.person_add_outlined,
              label: '초대',
              filled: false,
              onTap: () {}),
        ),
        const SizedBox(width: 8),
        _Pill(
          icon: Icons.settings_outlined,
          filled: false,
          square: true,
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => AlbumMenuSheet(album: album),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool filled;
  final bool square;
  final VoidCallback onTap;

  const _Pill({
    required this.icon,
    this.label,
    required this.filled,
    this.square = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : _P.ink;
    return Material(
      color: filled ? AppColors.main : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          width: square ? 44 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: filled ? null : Border.all(color: _P.ink.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: fg),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(label!,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: fg)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// VIEW SELECTOR
// ─────────────────────────────────────────
class _ViewSelector extends StatefulWidget {
  final AlbumViewMode current;
  final ValueChanged<AlbumViewMode> onChanged;

  const _ViewSelector({required this.current, required this.onChanged});

  @override
  State<_ViewSelector> createState() => _ViewSelectorState();
}

class _ViewSelectorState extends State<_ViewSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pillAnim;
  int _fromIndex = 0;
  int _toIndex   = 0;

  static const _modes = [
    (AlbumViewMode.memory, Icons.auto_awesome_rounded, '추억'),
    (AlbumViewMode.grid,   Icons.grid_view_rounded,    '격자'),
    (AlbumViewMode.date,   Icons.schedule_rounded,     '날짜'),
  ];

  int get _currentIndex =>
      _modes.indexWhere((e) => e.$1 == widget.current).clamp(0, 2);

  @override
  void initState() {
    super.initState();
    _fromIndex = _currentIndex;
    _toIndex   = _currentIndex;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pillAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_ViewSelector old) {
    super.didUpdateWidget(old);
    final newIdx = _currentIndex;
    if (newIdx != _toIndex) {
      _fromIndex = _toIndex;
      _toIndex   = newIdx;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final total     = constraints.maxWidth;
      final cellW     = total / _modes.length;
      const inset     = 4.0;
      const pillH     = 36.0;
      const trackH    = 44.0;

      return Container(
        height: trackH,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEAE6DE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // ── 슬라이딩 pill ──
            AnimatedBuilder(
              animation: _pillAnim,
              builder: (_, __) {
                final fromX = _fromIndex * cellW + inset;
                final toX   = _toIndex   * cellW + inset;
                final left  = fromX + (toX - fromX) * _pillAnim.value;

                return Positioned(
                  left: left,
                  top: (trackH - pillH) / 2,
                  width: cellW - inset * 2,
                  height: pillH,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.main,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.main.withOpacity(0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ── 탭 레이블 ──
            Row(
              children: List.generate(_modes.length, (i) {
                final item   = _modes[i];
                final active = widget.current == item.$1;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onChanged(item.$1),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: trackH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              item.$2,
                              key: ValueKey('${item.$1}_$active'),
                              size: 16,
                              color: active ? Colors.white : _P.sub,
                            ),
                          ),
                          const SizedBox(width: 5),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : AppColors.textSecondary,
                            ),
                            child: Text(item.$3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────
// GRID CONTENT
// ─────────────────────────────────────────
class _GridContent extends StatelessWidget {
  final List<Moment> moments;
  final Album album;

  const _GridContent({super.key, required this.moments, required this.album});

  @override
  Widget build(BuildContext context) {
    final photos = moments.expand((m) => m.photos).toList()
      ..sort((a, b) {
        final byDate = b.photoDate.compareTo(a.photoDate); // 날짜 내림차순
        if (byDate != 0) return byDate;
        return b.createdAt.compareTo(a.createdAt);
      });
    if (photos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: photos.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => Get.toNamed(
            Routes.photoDetail,
            arguments: {
              'photos': photos,
              'initialIndex': i,
              'album': album,
            },
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SmartImage(
              imageUrl: photos[i].thumbnailUrl ?? photos[i].imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// MEMORY CONTENT
// ─────────────────────────────────────────
class _MemoryContent extends StatelessWidget {
  final List<Moment> moments;
  final Album album;

  const _MemoryContent({super.key, required this.moments, required this.album});

  @override
  Widget build(BuildContext context) {
    // 날짜 내림차순 (최신 추억 먼저)
    final sorted = List<Moment>.of(moments)
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        return b.photos.first.createdAt.compareTo(a.photos.first.createdAt);
      });

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shrinkWrap : true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => MomentCard(moment: sorted[i], album: album),
    );
  }
}

// ─────────────────────────────────────────
// DATE CONTENT
// ─────────────────────────────────────────
class _DateContent extends StatelessWidget {
  final List<Moment> moments;
  final Album album;

  const _DateContent({super.key, required this.moments, required this.album});

  String _formatHeader(String date) {
    try {
      final p = date.split('-');
      if (p.length < 3) return date;
      final dt = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      const days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      return '${dt.year}년 ${dt.month}월 ${dt.day}일  ${days[dt.weekday - 1]}';
    } catch (_) {
      return date;
    }
  }


  @override
  Widget build(BuildContext context) {

    final byDate = <String, List<Photo>>{};
    for (final m in moments) {
      byDate.putIfAbsent(m.date, () => []).addAll(m.photos);
    }
    final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dates.length,
      itemBuilder: (_, i) {
        final date = dates[i];
        final photos = byDate[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(_formatHeader(date),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _P.ink,
                          letterSpacing: -0.2)),
                  const Spacer(),
                  Text('${photos.length}장',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _P.accent)),
                ],
              ),
            ),
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
              ),
              itemCount: photos.length > 6 ? 6 : photos.length,
              itemBuilder: (_, j) {
                final isOverlay = j == 5 && photos.length > 6;
                return GestureDetector(
                  onTap: () => Get.toNamed(
                    Routes.photoDetail,
                    arguments: {
                      'photos': photos,
                      'initialIndex': j,
                      'album': album,
                    },
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SmartImage(
                          imageUrl: photos[j].thumbnailUrl ?? photos[j].imageUrl,
                          fit: BoxFit.cover,
                        ),
                        if (isOverlay)
                          Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: Text('+${photos.length - 6}',
                                style: const TextStyle(
                                    color: AppColors.cardBg,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// 오프라인 배너
// ─────────────────────────────────────────
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
            Text('오프라인 - 저장된 사진만 표시됩니다',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    });
  }
}