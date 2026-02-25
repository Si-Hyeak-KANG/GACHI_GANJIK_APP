import 'package:get/get.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../data/sources/firebase/firebase_storage_source.dart';
import '../../data/sources/local/photo_local_source.dart';
import '../../data/sources/remote/mock/mock_photo_remote_source.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../presentation/controllers/photo/album_detail_controller.dart';

class AlbumDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final albumId = args['albumId'] as String;  // ✅ int → String

    Get.lazyPut<PhotoRepository>(
          () => PhotoRepositoryImpl(
        remoteSource: MockPhotoRemoteSource(),
        localSource: PhotoLocalSource(),
        storageSource: FirebaseStorageSource(),
      ),
    );

    Get.lazyPut(
          () => AlbumDetailController(
        photoRepository: Get.find(),
        albumId: albumId,
      ),
    );
  }
}