import 'package:get/get.dart';
import '../../presentation/controllers/album/create_album_controller.dart';

class CreateAlbumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
          () => CreateAlbumController(albumRepository: Get.find()),
    );
  }
}