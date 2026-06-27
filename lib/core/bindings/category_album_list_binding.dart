import 'package:get/get.dart';
import '../../../domain/entities/album.dart';
import '../../presentation/controllers/album/category_album_list_controller.dart';

class CategoryAlbumListBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    Get.lazyPut(
          () => CategoryAlbumListController(
        category: args['category'] as String,
        allAlbums: args['albums'] as List<Album>,
      ),
    );
  }
}