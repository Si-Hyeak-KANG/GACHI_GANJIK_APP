import 'package:get/get.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../utils/connectivity_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage
    Get.put(SecureStorage(), permanent: true);
    Get.put(LocalStorage(), permanent: true);

    // Network
    Get.put(DioClient(Get.find()), permanent: true);

    // Utils
    Get.put(ConnectivityService(), permanent: true);
  }
}