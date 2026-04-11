import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/enum/album_role.dart';
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

          // 앨범 제목 + 권한 뱃지
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
                // OWNER / ADMIN 모두 뱃지 표시
                if (album.albumRole == AlbumRole.owner ||
                    album.albumRole == AlbumRole.admin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

          // 공유하기 (OWNER/ADMIN)
          if (album.albumRole.canManage) ...[
            _MenuItem(
              icon: Icons.share,
              title: '앨범 공유하기',
              onTap: () {
                Get.back();
                showDialog(
                  context: context,
                  builder: (_) => AlbumShareDialog(album: album),
                );
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],

          // 커버 사진 등록 (OWNER/ADMIN)
          if (album.albumRole.canManage) ...[
            _MenuItem(
              icon: Icons.image_outlined,
              title: '커버 사진 등록',
              onTap: () {
                Get.back();
                Get.find<AlbumDetailController>().pickCoverImage();
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],

          // 앨범 정보 수정 (OWNER/ADMIN)
          if (album.albumRole.canManage) ...[
            _MenuItem(
              icon: Icons.edit_outlined,
              title: '앨범 정보 수정',
              onTap: () {
                Get.back();
                Get.toNamed(Routes.editAlbum, arguments: {'album': album});
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],

          // 사진 전체 다운로드
          _MenuItem(
            icon: Icons.download,
            title: '사진 전체 다운로드',
            subtitle: '준비 중',
            onTap: () {
              Get.back();
              Get.snackbar('준비 중', '사진 전체 다운로드 기능은 곧 제공될 예정입니다',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),

          const Divider(height: 1, color: AppColors.divider),

          // 삭제 / 나가기
          _MenuItem(
            icon: album.albumRole.canDelete
                ? Icons.delete_outline
                : Icons.logout,
            title: album.albumRole.canDelete ? '앨범 삭제' : '앨범 나가기',
            isDestructive: true,
            onTap: () {
              Get.back(); // 바텀시트 닫기
              _showDeleteConfirmDialog();
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── context 없이 Get.dialog 사용 → deactivated 오류 해결 ──
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
            child: const Text(
              '취소',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // 다이얼로그 닫기
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
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          ? Text(
        subtitle!,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      )
          : const Icon(Icons.chevron_right, color: AppColors.inactive),
      onTap: onTap,
    );
  }
}