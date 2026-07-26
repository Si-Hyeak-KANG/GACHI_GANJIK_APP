import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/album_member.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../domain/repositories/photo_repository.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import '../album/album_list_controller.dart';

class AlbumDetailController extends GetxController {
  final PhotoRepository _photoRepository;
  final AlbumRepository _albumRepository;
  final String albumId;

  AlbumDetailController({
    required PhotoRepository photoRepository,
    required AlbumRepository albumRepository,
    required this.albumId,
  })  : _photoRepository = photoRepository,
        _albumRepository = albumRepository;

  final RxList<Moment> moments = <Moment>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<AlbumMember> members = <AlbumMember>[].obs;
  final RxBool isMembersLoading = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchMoments();
    fetchMembers();
  }

  @override
  void onClose() {
    _refreshAlbumList();
    super.onClose();
  }

  Future<void> fetchMoments() async {
    isLoading.value = true;
    try {
      final result = await _photoRepository.getAlbumMoments(albumId);
      moments.assignAll(result);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('오류', '사진을 불러오지 못했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMembers() async {
    isMembersLoading.value = true;
    try {
      final result = await _albumRepository.getMembers(albumId);
      members.assignAll(result);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      // 멤버 조회 실패는 silent
    } finally {
      isMembersLoading.value = false;
    }
  }

  // ── 커버 사진 등록 ──────────────────────────────
  Future<void> pickCoverImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    Get.snackbar('준비 중', '커버 사진 등록은 앨범 수정 API 연동 후 지원됩니다',
        snackPosition: SnackPosition.BOTTOM);
  }

  // ── 앨범 삭제 (OWNER만) ──────────────────────────
  Future<void> deleteAlbum() async {
    try {
      await _albumRepository.deleteAlbum(albumId);
      if (Get.isRegistered<AlbumListController>()) {
        Get.find<AlbumListController>()
            .albums
            .removeWhere((a) => a.id == albumId);
      }
      Get.until((route) => route.settings.name == Routes.home);
      Get.snackbar('삭제 완료', '앨범이 삭제되었습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── 앨범 나가기 (MEMBER/ADMIN) ───────────────────
  Future<void> leaveAlbum() async {
    try {
      await _albumRepository.leaveAlbum(albumId);
      if (Get.isRegistered<AlbumListController>()) {
        Get.find<AlbumListController>()
            .albums
            .removeWhere((a) => a.id == albumId);
      }
      Get.until((route) => route.settings.name == Routes.home);
      Get.snackbar('완료', '앨범에서 나왔습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _refreshAlbumList() {
    if (Get.isRegistered<AlbumListController>()) {
      Get.find<AlbumListController>().fetchAlbums(silent: true);
    }
  }
}