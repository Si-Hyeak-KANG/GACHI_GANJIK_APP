import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/album_member.dart';
import '../../../domain/enum/album_role.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/album/album_detail_controller.dart';
import 'album_share_dialog.dart';

class AlbumMenuSheet extends StatelessWidget {
  final Album album;

  const AlbumMenuSheet({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.inactive,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    album.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (album.albumRole == AlbumRole.owner ||
                    album.albumRole == AlbumRole.admin)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mainLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      album.albumRole == AlbumRole.owner ? 'OWNER' : 'ADMIN',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.main,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),

          // 앨범 정보 수정 (OWNER/ADMIN)
          if (album.albumRole.canManage) ...[
            _MenuItem(
              icon: Icons.edit_outlined,
              title: '앨범 정보 수정',
              subtitle: '제목, 기간, 설명, 썸네일 수정',
              onTap: () {
                Get.back();
                Get.toNamed(Routes.editAlbum, arguments: {'album': album});
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],

          // 참여 인원 관리 (OWNER/ADMIN)
          if (album.albumRole.canManage) ...[
            _MenuItem(
              icon: Icons.people_outline,
              title: '참여 인원 관리',
              subtitle: '참여 인원 추가 및 권한 설정',
              onTap: () {
                Get.back();
                _showMemberSheet(context);
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],

          // 앨범 공유 및 초대
          _MenuItem(
            icon: Icons.share_outlined,
            title: '앨범 공유 및 초대',
            subtitle: '앨범 코드 및 QR 확인',
            onTap: () {
              Get.back();
              showDialog(
                context: context,
                builder: (_) => AlbumShareDialog(album: album),
              );
            },
          ),

          const Divider(height: 1, color: AppColors.divider),

          // 사진 다운로드
          _MenuItem(
            icon: Icons.download_outlined,
            title: '사진 다운로드',
            onTap: () {
              Get.back();
              Get.snackbar('준비 중', '사진 다운로드 기능은 곧 제공될 예정입니다',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),

          const Divider(height: 1, color: AppColors.divider),

          // 앨범 삭제 / 나가기
          _MenuItem(
            icon: album.albumRole.canDelete
                ? Icons.delete_outline
                : Icons.logout,
            title: album.albumRole.canDelete ? '앨범 삭제' : '앨범 나가기',
            subtitle: album.albumRole.canDelete
                ? '앨범과 모든 데이터를 삭제합니다'
                : null,
            isDestructive: true,
            onTap: () {
              Get.back();
              _showDeleteConfirmDialog();
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MemberManagementSheet(album: album),
    );
  }

  void _showDeleteConfirmDialog() {
    final isDelete = album.albumRole.canDelete;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isDelete ? '앨범을 삭제할까요?' : '앨범에서 나갈까요?',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          isDelete
              ? '앨범을 삭제하면 모든 사진과 댓글을 더 이상 볼 수 없습니다.\n정말 삭제하시겠습니까?'
              : '앨범에서 나가면 더 이상 사진을 볼 수 없습니다.\n정말 나가시겠습니까?',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('취소',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              final controller = Get.find<AlbumDetailController>();
              if (isDelete) {
                controller.deleteAlbum();
              } else {
                controller.leaveAlbum();
              }
            },
            child: Text(
              isDelete ? '삭제' : '나가기',
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 멤버 관리 바텀시트 ─────────────────────────────────
class _MemberManagementSheet extends StatefulWidget {
  final Album album;

  const _MemberManagementSheet({required this.album});

  @override
  State<_MemberManagementSheet> createState() => _MemberManagementSheetState();
}

class _MemberManagementSheetState extends State<_MemberManagementSheet> {
  List<AlbumMember> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final repo = Get.find<AlbumRepository>();
      final members = await repo.getMembers(widget.album.id);
      if (mounted) setState(() => _members = members);
    } catch (e) {
      if (mounted) {
        Get.snackbar('오류', '멤버 목록을 불러오지 못했습니다',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRole(AlbumMember member, String newRole) async {
    try {
      final repo = Get.find<AlbumRepository>();
      await repo.updateMemberRole(widget.album.id, member.memberId, newRole);
      await _loadMembers();
      Get.snackbar('완료',
          newRole == 'ADMIN' ? '${member.nickname}님을 ADMIN으로 지정했습니다' : '${member.nickname}님의 ADMIN을 해제했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _kickMember(AlbumMember member) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('멤버 퇴장'),
        content: Text('${member.nickname}님을 앨범에서 내보내시겠어요?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('내보내기'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = Get.find<AlbumRepository>();
      await repo.kickMember(widget.album.id, member.memberId);
      await _loadMembers();
      Get.snackbar('완료', '${member.nickname}님을 내보냈습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  bool _canKick(AlbumMember member) {
    if (member.isOwner) return false;
    if (widget.album.albumRole == AlbumRole.owner) return true;
    if (widget.album.albumRole == AlbumRole.admin && member.isMember) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    '멤버 관리',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_isLoading)
                    Text(
                      '${_members.length}명',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(
                  child: CircularProgressIndicator(color: AppColors.main))
                  : ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _members.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
                itemBuilder: (_, index) {
                  final member = _members[index];
                  return _MemberTile(
                    member: member,
                    albumRole: widget.album.albumRole,
                    canKick: _canKick(member),
                    onToggleAdmin: widget.album.albumRole == AlbumRole.owner &&
                        !member.isOwner
                        ? () => _updateRole(
                      member,
                      member.isAdmin ? 'MEMBER' : 'ADMIN',
                    )
                        : null,
                    onKick: _canKick(member)
                        ? () => _kickMember(member)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final AlbumMember member;
  final AlbumRole albumRole;
  final bool canKick;
  final VoidCallback? onToggleAdmin;
  final VoidCallback? onKick;

  const _MemberTile({
    required this.member,
    required this.albumRole,
    required this.canKick,
    this.onToggleAdmin,
    this.onKick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.mainLight,
        backgroundImage: member.profileImageUrl != null
            ? CachedNetworkImageProvider(member.profileImageUrl!)
            : null,
        child: member.profileImageUrl == null
            ? Text(
          member.nickname.isNotEmpty ? member.nickname[0] : '?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.main,
          ),
        )
            : null,
      ),
      title: Row(
        children: [
          Text(
            member.nickname,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          if (!member.isMember)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: member.isOwner
                    ? AppColors.main
                    : AppColors.mainLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                member.roleDisplay,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color:
                  member.isOwner ? Colors.white : AppColors.main,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        member.userTag,
        style: const TextStyle(
            fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: member.isOwner
          ? null
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ADMIN 지정/해제 — OWNER만
          if (onToggleAdmin != null)
            TextButton(
              onPressed: onToggleAdmin,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                member.isAdmin ? 'ADMIN 해제' : 'ADMIN 지정',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.main,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // 강제 퇴장
          if (onKick != null)
            IconButton(
              icon: const Icon(Icons.logout,
                  size: 18, color: Colors.red),
              onPressed: onKick,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.textPrimary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : AppColors.textPrimary,
        ),
      ),
      trailing: subtitle != null
          ? Text(subtitle!,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary))
          : const Icon(Icons.chevron_right, color: AppColors.inactive),
      onTap: onTap,
    );
  }
}