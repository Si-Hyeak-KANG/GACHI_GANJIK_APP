import 'package:get/get.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../utils/connectivity_service.dart';
import '../../data/sources/remote/mock/mock_auth_remote_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/controllers/auth/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SecureStorage(), permanent: true);
    Get.put(LocalStorage(), permanent: true);   // onInit()이 자동 호출됨
    Get.put(DioClient(Get.find()), permanent: true);
    Get.put(ConnectivityService(), permanent: true);

    Get.lazyPut<AuthRepository>(
          () => AuthRepositoryImpl(
        remoteSource: MockAuthRemoteSource(),
        secureStorage: Get.find(),
        localStorage: Get.find(),
      ),
      fenix: true,
    );

    Get.put(
      AuthController(authRepository: Get.find()),
      permanent: true,
    );
  }
}