import 'package:get/get.dart';
import '../../../domain/repositories/photo_repository.dart';
import '../../presentation/controllers/camera/camera_controller.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraController>(
          () => CameraController(photoRepository: Get.find<PhotoRepository>()),
      fenix: true,
    );
  }
}