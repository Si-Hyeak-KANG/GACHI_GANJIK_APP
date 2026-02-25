import 'package:flutter/material.dart';
import 'package:gachiganjik_app/domain/enum/album_role.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/album.dart';

import 'album_share_dialog.dart';

class AlbumMenuSheet extends StatelessWidget {
  final Album album;

  const AlbumMenuSheet({
    super.key,
    required this.album,
  });

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
                if (album.albumRole.canManage)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mainLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      album.albumRole.displayName,
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

          if (album.albumRole.canManage)
            _MenuItem(
              icon: Icons.share,
              title: '앨범 공유하기',
              onTap: () {
                Navigator.pop(context);
                _showShareDialog(context);
              },
            ),

          if (album.albumRole.canManage)
            const Divider(height: 1, color: AppColors.divider),

          _MenuItem(
            icon: Icons.download,
            title: '사진 전체 다운로드',
            subtitle: '준비 중',
            onTap: () {
              Navigator.pop(context);
              Get.snackbar(
                '준비 중',
                '사진 전체 다운로드 기능은 곧 제공될 예정입니다',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),

          if (album.albumRole.canManage) ...[
            _MenuItem(
              icon: Icons.settings,
              title: '앨범 정보 관리',
              subtitle: '준비 중',
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  '준비 중',
                  '앨범 정보 관리 기능은 곧 제공될 예정입니다',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],

          const Divider(height: 1, color: AppColors.divider),

          _MenuItem(
            icon: album.albumRole.canDelete ? Icons.delete_outline : Icons.logout,
            title: album.albumRole.canDelete ? '앨범 삭제' : '앨범 나가기',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmDialog(context);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlbumShareDialog(album: album),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          album.albumRole.canDelete ? '앨범을 삭제할까요?' : '앨범에서 나갈까요?',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          album.albumRole.canDelete
              ? '앨범을 삭제하면 모든 사진과 댓글이 영구적으로 삭제됩니다.\n정말 삭제하시겠습니까?'
              : '앨범에서 나가면 더 이상 사진을 볼 수 없습니다.\n정말 나가시겠습니까?',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
              Get.snackbar(
                '준비 중',
                album.albumRole.canDelete
                    ? '앨범 삭제 기능은 곧 제공될 예정입니다'
                    : '앨범 나가기 기능은 곧 제공될 예정입니다',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text(
              album.albumRole.canDelete ? '삭제' : '나가기',
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
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      )
          : const Icon(
        Icons.chevron_right,
        color: AppColors.inactive,
      ),
      onTap: onTap,
    );
  }
}