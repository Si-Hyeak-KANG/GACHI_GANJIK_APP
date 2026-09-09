import 'package:get/get.dart';
import '../../presentation/controllers/auth/social_onboarding_controller.dart';

class SocialOnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocialOnboardingController>(
          () => SocialOnboardingController(authRepository: Get.find()),
    );
  }
}