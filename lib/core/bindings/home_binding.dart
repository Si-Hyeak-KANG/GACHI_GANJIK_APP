import 'package:get/get.dart';
import '../../core/services/websocket_service.dart';
import '../../data/repositories/album_repository_impl.dart';
import '../../data/sources/remote/mock/mock_album_remote_source.dart';
import '../../domain/repositories/album_repository.dart';
import '../../presentation/controllers/album/album_list_controller.dart';
import '../../presentation/controllers/camera/camera_controller.dart';
import '../../domain/repositories/photo_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // AlbumRepository - fenix: true로 HomeView 재진입 시 재생성
    Get.lazyPut<AlbumRepository>(
          () => AlbumRepositoryImpl(
        remoteSource: MockAlbumRemoteSource(),
      ),
      fenix: true,
    );

    Get.lazyPut<AlbumListController>(
          () => AlbumListController(
        albumRepository: Get.find(),
        wsService: Get.find<WebSocketService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CameraController>(
          () => CameraController(photoRepository: Get.find<PhotoRepository>()),
      fenix: true,
    );
  }
}