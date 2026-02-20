import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/storage/local_storage.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../controllers/auth/auth_controller.dart';

class SettingsController extends GetxController {
  final UserRepository _userRepository;
  final LocalStorage _localStorage;

  SettingsController({
    required UserRepository userRepository,
    required LocalStorage localStorage,
  })  : _userRepository = userRepository,
        _localStorage = localStorage;

  final RxString appVersion = ''.obs;
  final RxBool isNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
    _loadNotificationSetting();
  }

  // 앱 버전 로드
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = 'v${packageInfo.version}';
  }

  // 알림 설정 로드
  Future<void> _loadNotificationSetting() async {
    // SharedPreferences에서 알림 설정 로드
    // 기본값은 true
    isNotificationEnabled.value = true; // TODO: localStorage에서 로드
  }

  // 알림 설정 토글
  Future<void> toggleNotification(bool value) async {
    isNotificationEnabled.value = value;
    // TODO: localStorage에 저장

    Get.snackbar(
      '알림 설정',
      value ? '알림이 활성화되었습니다' : '알림이 비활성화되었습니다',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // 공지사항
  void openNotice() {
    // TODO: 실제 URL로 교체
    _launchURL('https://www.notion.so');
  }

  // 이용약관
  void openTerms() {
    // TODO: 실제 URL로 교체
    _launchURL('https://www.notion.so/terms');
  }

  // 개인정보처리방침
  void openPrivacy() {
    // TODO: 실제 URL로 교체
    _launchURL('https://www.notion.so/privacy');
  }

  // 문의하기 (이메일)
  Future<void> openInquiry() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@gachiganjik.com',
      query: 'subject=문의하기&body=',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        '오류',
        '이메일 앱을 열 수 없습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // URL 열기
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        '오류',
        'URL을 열 수 없습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 회원탈퇴
  Future<void> deleteAccount() async {
    // 확인 다이얼로그
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text(
          '정말로 탈퇴하시겠어요?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 1. 서버에서 계정 삭제 (Mock)
      await _userRepository.deleteAccount();

      // 2. 로컬 데이터 삭제
      await _localStorage.clearAll();

      // 3. Isar 데이터 삭제 (Phase 6에서 구현 예정)
      // await DatabaseService.clearAll();

      // 4. 로그아웃
      Get.find<AuthController>().logout();

      Get.snackbar(
        '완료',
        '회원탈퇴가 완료되었습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '회원탈퇴에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}