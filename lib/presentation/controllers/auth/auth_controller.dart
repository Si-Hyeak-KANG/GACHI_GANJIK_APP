import 'package:get/get.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // 반응형 상태
  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoggedInState = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // 앱 시작 시 로그인 상태 확인
  Future<void> _checkAuthStatus() async {
    final loggedIn = await _authRepository.isLoggedIn();
    isLoggedInState.value = loggedIn;
  }

  Future<bool> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }

  // 로그인 성공 시 상태 업데이트
  void onLoginSuccess(User user) {
    currentUser.value = user;
    isLoggedInState.value = true;
  }

  // 로그아웃
  Future<void> logout() async {
    await _authRepository.logout();
    currentUser.value = null;
    isLoggedInState.value = false;
    Get.offAllNamed(Routes.login);
  }

}