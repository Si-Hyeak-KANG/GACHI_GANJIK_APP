import 'package:get/get.dart';
import '../../presentation/controllers/auth/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
          () => LoginController(authRepository: Get.find()),
    );
  }
}