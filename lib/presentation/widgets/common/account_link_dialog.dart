import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';

/// 동일 이메일의 기존 계정이 발견됐을 때 연동 여부를 확인하는 공용 다이얼로그.
/// - 연동하기: [onLink]
/// - 기존 방식으로 로그인: [onGoLogin]
Future<void> showAccountLinkDialog({
  required String? maskedEmail,
  required VoidCallback onLink,
  required VoidCallback onGoLogin,
}) {
  return Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '이미 가입된 이메일이에요',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Text(
        '${maskedEmail ?? '해당'} 이메일로 가입된 계정이 있어요.\n'
            '이 계정에 이번 로그인 방식을 연동할까요?',
        style: const TextStyle(
            fontSize: 14, height: 1.5, color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            onGoLogin();
          },
          child: const Text('기존 방식으로 로그인',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: () {
            Get.back();
            onLink();
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.main),
          child: const Text('연동하기'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}