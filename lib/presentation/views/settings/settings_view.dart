import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/settings/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // 알림 설정
          Obx(() => _SettingToggleItem(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            value: controller.isNotificationEnabled.value,
            onChanged: controller.toggleNotification,
          )),
          const Divider(height: 1, indent: 60),

          // 공지사항
          _SettingItem(
            icon: Icons.campaign_outlined,
            title: '공지사항',
            onTap: controller.openNotice,
          ),
          const Divider(height: 1, indent: 60),

          // 이용약관
          _SettingItem(
            icon: Icons.description_outlined,
            title: '이용약관',
            onTap: controller.openTerms,
          ),
          const Divider(height: 1, indent: 60),

          // 개인정보처리방침
          _SettingItem(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보처리방침',
            onTap: controller.openPrivacy,
          ),
          const Divider(height: 1, indent: 60),

          // 문의하기
          _SettingItem(
            icon: Icons.email_outlined,
            title: '문의하기',
            onTap: controller.openInquiry,
          ),
          const Divider(height: 1, indent: 60),

          // 앱 버전
          Obx(() => _SettingItem(
            icon: Icons.info_outline,
            title: '앱 버전',
            trailing: Text(
              controller.appVersion.value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          )),
          const Divider(height: 1, indent: 60),

          const SizedBox(height: 24),

          // 회원탈퇴
          _SettingItem(
            icon: Icons.logout,
            title: '회원탈퇴',
            isDestructive: true,
            onTap: controller.deleteAccount,
          ),
        ],
      ),
    );
  }
}

// 설정 아이템
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? const Icon(
            Icons.chevron_right,
            color: AppColors.inactive,
          )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

// 토글 아이템
class _SettingToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.main,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}