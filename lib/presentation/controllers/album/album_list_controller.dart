import 'package:get/get.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../core/network/network_exception.dart';

class AlbumListController extends GetxController {
  final AlbumRepository _albumRepository;

  AlbumListController({required AlbumRepository albumRepository})
      : _albumRepository = albumRepository;

  final RxList<Album> albums = <Album>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isJoining = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAlbums();
  }

  // 앨범 목록 조회
  Future<void> fetchAlbums() async {
    isLoading.value = true;
    try {
      final result = await _albumRepository.getAlbums();
      albums.assignAll(result);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('오류', '앨범 목록을 불러오지 못했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // 앨범 입장 (바텀 시트에서 호출)
  Future<void> joinAlbum(String inviteCode) async {
    if (inviteCode.trim().isEmpty) {
      Get.snackbar('알림', '초대 코드를 입력해주세요',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isJoining.value = true;
    try {
      final album = await _albumRepository.joinAlbum(inviteCode.trim());

      // 이미 목록에 없으면 맨 앞에 추가
      final exists = albums.any((a) => a.id == album.id);
      if (!exists) {
        albums.insert(0, album);
      }

      Get.back(); // 바텀 시트 닫기
      Get.snackbar('입장 완료', '${album.title}에 참여했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('실패', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isJoining.value = false;
    }
  }

  void addAlbum(Album album) {
    albums.insert(0, album);
  }
}