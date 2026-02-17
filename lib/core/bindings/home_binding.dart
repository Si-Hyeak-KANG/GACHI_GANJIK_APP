import 'package:get/get.dart';
import '../../data/repositories/album_repository_impl.dart';
import '../../data/sources/remote/mock/mock_album_remote_source.dart';
import '../../domain/repositories/album_repository.dart';
import '../../presentation/controllers/album/album_list_controller.dart';

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
          () => AlbumListController(albumRepository: Get.find()),
      fenix: true,
    );
  }
}