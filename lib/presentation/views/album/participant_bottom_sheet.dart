import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/album_member.dart';
import '../../controllers/album/album_detail_controller.dart';

class ParticipantBottomSheet extends StatelessWidget {
  final Album album;

  const ParticipantBottomSheet({super.key, required this.album});

  static void show(BuildContext context, Album album) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ParticipantBottomSheet(album: album),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 핸들바
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 타이틀
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text(
                  '참여중',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                GetX<AlbumDetailController>(
                  builder: (c) => Text(
                    '${c.members.length}명',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.main,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 멤버 목록
          Expanded(
            child: GetX<AlbumDetailController>(
              builder: (c) {
                if (c.isMembersLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.main),
                  );
                }
                if (c.members.isEmpty) {
                  return const Center(
                    child: Text(
                      '멤버 정보를 불러올 수 없습니다',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: c.members.length,
                  itemBuilder: (_, i) => _MemberTile(member: c.members[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final AlbumMember member;
  const _MemberTile({required this.member});

  Color get _avatarColor {
    final colors = [
      AppColors.main,
      const Color(0xFF4A90D9),
      const Color(0xFFD4AC0D),
      const Color(0xFF27AE60),
      const Color(0xFF8E7B6B),
      const Color(0xFF7B5EA7),
    ];
    return colors[member.nickname.hashCode.abs() % colors.length];
  }

  _BadgeStyle get _badge {
    switch (member.role) {
      case 'OWNER':
        return _BadgeStyle('Owner', AppColors.main, const Color(0xFFFFF1EE));
      case 'ADMIN':
        return _BadgeStyle('Admin', const Color(0xFF4A90D9), const Color(0xFFEBF4FF));
      default:
        return _BadgeStyle('Member', const Color(0xFF27AE60), const Color(0xFFEBFAF0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 아바타
          if (member.profileImageUrl != null && member.profileImageUrl!.isNotEmpty)
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(member.profileImageUrl!),
              backgroundColor: _avatarColor,
            )
          else
            CircleAvatar(
              radius: 24,
              backgroundColor: _avatarColor,
              child: Text(
                member.nickname.isNotEmpty ? member.nickname[0] : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),

          const SizedBox(width: 14),

          // 이름 + 태그
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.nickname,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  member.userTag,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 역할 Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: badge.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badge.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStyle {
  final String label;
  final Color color;
  final Color bg;
  _BadgeStyle(this.label, this.color, this.bg);
}