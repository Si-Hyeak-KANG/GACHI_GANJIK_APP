import 'package:get/get.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/sources/firebase/firebase_storage_source.dart';
import '../../data/sources/remote/mock/mock_user_remote_source.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/controllers/settings/settings_controller.dart';
import '../../core/storage/local_storage.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // UserRepository가 없으면 생성
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(
            () => UserRepositoryImpl(
          remoteSource: MockUserRemoteSource(),
          storageSource: FirebaseStorageSource(),
        ),
      );
    }

    Get.lazyPut(
          () => SettingsController(
        userRepository: Get.find(),
        localStorage: Get.find(),
      ),
    );
  }
}