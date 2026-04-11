import 'package:get/get.dart';
import '../../data/sources/firebase/firebase_storage_source.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/album_repository.dart';
import '../../presentation/controllers/album/edit_album_controller.dart';

class EditAlbumBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final album = args['album'] as Album;

    Get.lazyPut(
          () => EditAlbumController(
        albumRepository: Get.find<AlbumRepository>(),
        storageSource: Get.find<FirebaseStorageSource>(),
        album: album,
      ),
    );
  }
}