import 'package:get/get.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/network/network_exception.dart';

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
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // 프로필 업데이트 후 재조회
  void updateUser(User updatedUser) {
    user.value = updatedUser;
  }
}