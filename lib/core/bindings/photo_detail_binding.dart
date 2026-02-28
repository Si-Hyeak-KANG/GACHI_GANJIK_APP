import 'package:get/get.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../data/sources/remote/comment_remote_source.dart';
import '../../data/sources/remote/mock/mock_comment_remote_source.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/entities/photo.dart';
import '../../domain/entities/album.dart';
import '../../presentation/controllers/photo/photo_detail_controller.dart';

class PhotoDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final photos = args['photos'] as List<Photo>;
    final initialIndex = args['initialIndex'] as int;
    final album = args['album'] as Album;

    Get.lazyPut<CommentRemoteSource>(() => MockCommentRemoteSource());

    Get.lazyPut<CommentRepository>(
          () => CommentRepositoryImpl(remoteSource: Get.find()),
    );

    Get.lazyPut(
          () => PhotoDetailController(
        commentRepository: Get.find(),
        photoRepository: Get.find<PhotoRepositoryImpl>(),
        photos: photos,
        initialIndex: initialIndex,
        album: album,
      ),
    );
  }
}