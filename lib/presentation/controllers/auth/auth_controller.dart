import 'package:get/get.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/guest_repository.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/storage/secure_storage.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final GuestRepository _guestRepository;
  final SecureStorage _secureStorage;

  AuthController({
    required AuthRepository authRepository,
    required GuestRepository guestRepository,
    required SecureStorage secureStorage,
  })  : _authRepository = authRepository,
        _guestRepository = guestRepository,
        _secureStorage = secureStorage;

  // 반응형 상태
  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoggedInState = false.obs;
  final RxBool isGuestState = false.obs;


  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // 앱 시작 시 로그인 상태 확인
  Future<void> _checkAuthStatus() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (loggedIn) {
      isLoggedInState.value = true;
      return;
    }
    // 일반 로그인 없으면 guest 복원 시도
    final guestKey = await _secureStorage.getGuestKey();
    if (guestKey != null && guestKey.isNotEmpty) {
      try {
        await _guestRepository.restore(guestKey);
        isGuestState.value = true;
      } catch (_) {
        // 복원 실패 시 guest 세션 초기화
        await _guestRepository.clearGuestSession();
      }
    }
  }

  Future<bool> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }

  // 로그인 성공 시 상태 업데이트
  void onLoginSuccess(User user) {
    currentUser.value = user;
    isLoggedInState.value = true;
    isGuestState.value = false;
  }

  // 로그아웃
  Future<void> logout() async {
    await _authRepository.logout();
    currentUser.value = null;
    isLoggedInState.value = false;
    Get.offAllNamed(Routes.login);
  }

}