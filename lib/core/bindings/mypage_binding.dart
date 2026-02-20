import 'package:get/get.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/sources/firebase/firebase_storage_source.dart';
import '../../data/sources/remote/mock/mock_user_remote_source.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/controllers/user/user_controller.dart';

class MyPageBinding extends Bindings {
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

    // UserController가 없으면 생성
    if (!Get.isRegistered<UserController>()) {
      Get.lazyPut(
            () => UserController(userRepository: Get.find()),
      );
    }
  }
}