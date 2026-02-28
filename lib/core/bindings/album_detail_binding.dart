import 'package:get/get.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../presentation/controllers/album/album_detail_controller.dart';

class AlbumDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final albumId = args['albumId'] as String;

    // PhotoRepositoryImpl은 initial_binding에서 이미 싱글톤으로 등록됨
    // 새 인스턴스를 만들면 Mock 데이터 상태가 분리되어 업로드 후 목록에 반영 안 됨
    Get.lazyPut(
          () => AlbumDetailController(
        photoRepository: Get.find<PhotoRepositoryImpl>(),
        albumId: albumId,
      ),
    );
  }
}