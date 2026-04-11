import 'package:get/get.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import '../auth/auth_controller.dart';

// → AuthController는 인증 상태만 관리
// → UserController는 프로필 정보 관리
class UserController extends GetxController {
  final UserRepository _userRepository;

  UserController({required UserRepository userRepository})
      : _userRepository = userRepository;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final result = await _userRepository.getCurrentUser();
      user.value = result;
    } on NetworkException catch (e) {
      if (e.type == NetworkExceptionType.noInternet ||
          e.type == NetworkExceptionType.connectionTimeout) {
        // 서버 미연결 — user가 null이면 로그아웃, 있으면 유지
        if (user.value == null) {
          await _logoutAndGoLogin('서버에 연결할 수 없습니다.\n다시 로그인해주세요.');
        }
        // user.value가 이미 있으면 (이전 세션 데이터) 그냥 유지
      } else if (e.type == NetworkExceptionType.unauthorized ||
          e.type == NetworkExceptionType.forbidden) {
        // 토큰 만료 또는 인증 실패 → 로그아웃
        await _logoutAndGoLogin('로그인이 만료되었습니다.\n다시 로그인해주세요.');
      } else {
        Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      if (user.value == null) {
        await _logoutAndGoLogin('사용자 정보를 불러올 수 없습니다.\n다시 로그인해주세요.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void updateUser(User updatedUser) {
    user.value = updatedUser;
  }

  Future<void> _logoutAndGoLogin(String message) async {
    try {
      await Get.find<AuthController>().logout();
    } catch (_) {
      // AuthController logout 실패해도 로그인 화면으로 이동
      Get.offAllNamed(Routes.login);
    }
    Get.snackbar(
      '알림',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}