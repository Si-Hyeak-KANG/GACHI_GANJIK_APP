import 'package:get/get.dart';
import '../../../domain/entities/album.dart';

enum AlbumSortType { latest, eventDate, name, photoCount }

class CategoryAlbumListController extends GetxController {
  final String category;
  final List<Album> allAlbums;

  CategoryAlbumListController({
    required this.category,
    required this.allAlbums,
  });

  final Rx<AlbumSortType> sortType = AlbumSortType.latest.obs;
  final RxList<Album> albums = <Album>[].obs;

  @override
  void onInit() {
    super.onInit();
    _applySortAndFilter();
    ever(sortType, (_) => _applySortAndFilter());
  }

  void _applySortAndFilter() {
    final filtered = allAlbums
        .where((a) => a.categories.contains(category))
        .toList();

    switch (sortType.value) {
      case AlbumSortType.latest:
        filtered.sort((a, b) {
          final aTime = a.lastPhotoUploadedAt ?? a.createdAt;
          final bTime = b.lastPhotoUploadedAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });
      case AlbumSortType.name:
        filtered.sort((a, b) => a.title.compareTo(b.title));
      case AlbumSortType.eventDate:
        filtered.sort((a, b) => b.eventStartDate.compareTo(a.eventStartDate));
      case AlbumSortType.photoCount:
        filtered.sort((a, b) => b.photoCount.compareTo(a.photoCount));
    }

    albums.assignAll(filtered);
  }

  void setSort(AlbumSortType type) => sortType.value = type;
}