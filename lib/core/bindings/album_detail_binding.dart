import 'package:get/get.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../data/sources/firebase/firebase_storage_source.dart';
import '../../data/sources/local/photo_local_source.dart';
import '../../data/sources/remote/mock/mock_photo_remote_source.dart';
import '../../data/sources/remote/mock/mock_reaction_remote_source.dart';
import '../../data/sources/remote/photo_remote_source.dart';
import '../../data/sources/remote/reaction_remote_source.dart';
import '../../presentation/controllers/album/album_detail_controller.dart';

class AlbumDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final albumId = args['albumId'] as String;

    Get.lazyPut<PhotoRemoteSource>(() => MockPhotoRemoteSource());
    Get.lazyPut<ReactionRemoteSource>(() => MockReactionRemoteSource());

    Get.lazyPut<PhotoRepositoryImpl>(
          () => PhotoRepositoryImpl(
        remoteSource: Get.find(),
        reactionRemoteSource: Get.find(),
        localSource: PhotoLocalSource(),
        storageSource: FirebaseStorageSource(),
      ),
    );

    Get.lazyPut(
          () => AlbumDetailController(
        photoRepository: Get.find<PhotoRepositoryImpl>(),
        albumId: albumId,
      ),
    );
  }
}