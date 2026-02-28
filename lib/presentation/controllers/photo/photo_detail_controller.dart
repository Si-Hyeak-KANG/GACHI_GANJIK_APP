import 'package:flutter/material.dart';
import 'package:gachiganjik_app/domain/enum/album_role.dart';
import 'package:get/get.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/comment_repository.dart';
import '../../../data/repositories/photo_repository_impl.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/utils/gallery_saver.dart';
import '../auth/auth_controller.dart';

class PhotoDetailController extends GetxController {
  final CommentRepository _commentRepository;
  final PhotoRepositoryImpl _photoRepository;
  final List<Photo> photos;
  final int initialIndex;
  final Album album;

  PhotoDetailController({
    required CommentRepository commentRepository,
    required PhotoRepositoryImpl photoRepository,
    required this.photos,
    required this.initialIndex,
    required this.album,
  })  : _commentRepository = commentRepository,
        _photoRepository = photoRepository;

  late final PageController pageController;
  final RxInt currentIndex = 0.obs;
  final RxBool isLiked = false.obs;
  final RxInt likeCount = 0.obs;
  final RxList<Comment> comments = <Comment>[].obs;
  final RxBool isLoadingComments = false.obs;
  final RxBool isAddingComment = false.obs;
  final RxBool isSavingImage = false.obs;
  final RxBool isModalExpanded = false.obs;

  final commentController = TextEditingController();

  Photo get currentPhoto => photos[currentIndex.value];
  bool get canDownload => album.albumRole.canManage;

  String get _currentUserId {
    try {
      return Get.find<AuthController>().currentUser.value?.userId ?? '';
    } catch (_) {
      return '';
    }
  }

  String get _currentUserNickname {
    try {
      return Get.find<AuthController>().currentUser.value?.nickname ?? '';
    } catch (_) {
      return '';
    }
  }

  // View에서 닉네임이 필요한 경우 사용
  String get currentUserNickname => _currentUserNickname;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    _loadPhotoData();
  }

  @override
  void onClose() {
    pageController.dispose();
    commentController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    if (isModalExpanded.value) isModalExpanded.value = false;
    _loadPhotoData();
  }

  void expandModal() {
    isModalExpanded.value = true;
    if (comments.isEmpty && !isLoadingComments.value) {
      _loadComments();
    }
  }

  void collapseModal() {
    isModalExpanded.value = false;
    FocusScope.of(Get.context!).unfocus();
  }

  Future<void> _loadPhotoData() async {
    likeCount.value = currentPhoto.likeCount;
    // 좋아요 초기 상태는 서버에서 받아오지 않으므로 false로 초기화
    // (실제 서버에서 isLiked 필드가 내려오면 photo.isLiked로 처리)
    isLiked.value = false;
  }

  Future<void> _loadComments() async {
    isLoadingComments.value = true;
    try {
      // CommentRepository는 photoId만 받으므로 albumId::photoId 형태로 전달
      final compositeId = '${album.id}::${currentPhoto.id}';
      final result = await _commentRepository.getComments(compositeId);
      comments.assignAll(result);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> toggleLike() async {
    // 낙관적 업데이트: 즉시 UI 반영 후 서버 요청
    final prevLiked = isLiked.value;
    final prevCount = likeCount.value;

    isLiked.value = !prevLiked;
    likeCount.value = isLiked.value ? prevCount + 1 : prevCount - 1;

    try {
      final result = await _photoRepository.toggleLike(
        album.id,
        currentPhoto.id,
      );
      // 서버 결과로 덮어씌움 (정확성 보장)
      isLiked.value = result.isLiked;
      likeCount.value = result.likeCount;
    } catch (_) {
      // 서버 실패 시 롤백
      isLiked.value = prevLiked;
      likeCount.value = prevCount;
      Get.snackbar(
        '오류',
        '좋아요 처리에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    isAddingComment.value = true;
    try {
      final compositeId = '${album.id}::${currentPhoto.id}';
      final comment = await _commentRepository.addComment(compositeId, text);
      comments.add(comment);
      commentController.clear();
      FocusScope.of(Get.context!).unfocus();

      Get.snackbar(
        '완료',
        '댓글이 추가되었습니다',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAddingComment.value = false;
    }
  }

  Future<void> deleteComment(int index) async {
    final comment = comments[index];

    // 본인 댓글 여부 확인 (userId 기준)
    if (comment.userId != _currentUserId) {
      Get.snackbar(
        '알림',
        '본인의 댓글만 삭제할 수 있습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('이 댓글을 삭제하시겠어요?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final compositeId = '${album.id}::${currentPhoto.id}';
      await _commentRepository.deleteComment(compositeId, comment.commentId);
      comments.removeAt(index);

      Get.snackbar(
        '완료',
        '댓글이 삭제되었습니다',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> saveImage() async {
    if (!canDownload) {
      Get.snackbar(
        '권한 없음',
        '관리자만 사진을 다운로드할 수 있습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSavingImage.value = true;
    try {
      final success = await GallerySaver.saveImageFromUrl(currentPhoto.imageUrl);
      Get.snackbar(
        success ? '완료' : '실패',
        success ? '갤러리에 저장되었습니다' : '이미지 저장에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        e.toString().contains('권한')
            ? '갤러리 접근 권한이 필요합니다'
            : '이미지 저장에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingImage.value = false;
    }
  }
}