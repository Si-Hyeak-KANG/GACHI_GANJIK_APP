import 'package:get/get.dart';
import '../../presentation/controllers/auth/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
          () => SignupController(authRepository: Get.find()),
    );
  }
}