import 'package:get/get.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/repositories/album_repository.dart';
import '../../presentation/controllers/album/album_detail_controller.dart';

class AlbumDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final albumId = args['albumId'] as String;

    Get.lazyPut(
          () => AlbumDetailController(
        photoRepository: Get.find<PhotoRepositoryImpl>(),
        albumRepository: Get.find<AlbumRepository>(),
        albumId: albumId,
      ),
    );
  }
}