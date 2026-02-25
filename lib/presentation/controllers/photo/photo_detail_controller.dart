import 'package:flutter/material.dart';
import 'package:gachiganjik_app/domain/enum/album_role.dart';
import 'package:get/get.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/comment_repository.dart';
import '../../../data/sources/local/like_local_source.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/utils/gallery_saver.dart';

class PhotoDetailController extends GetxController {
  final CommentRepository _commentRepository;
  final LikeLocalSource _likeLocalSource;
  final List<Photo> photos;
  final int initialIndex;
  final Album album;

  PhotoDetailController({
    required CommentRepository commentRepository,
    required LikeLocalSource likeLocalSource,
    required this.photos,
    required this.initialIndex,
    required this.album,
  })  : _commentRepository = commentRepository,
        _likeLocalSource = likeLocalSource;

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
  bool get canDownload => album.albumRole.canManage;  // ✅ role → albumRole

  // ✅ 현재 사용자 정보 (추후 AuthController에서 가져오기)
  String get _currentUserId => 'user-uuid-1';
  String get _currentUserNickname => '석스키';
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
    if (isModalExpanded.value) {
      isModalExpanded.value = false;
    }
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
    await _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    try {
      // ✅ String UUID 사용
      isLiked.value = await _likeLocalSource.isLiked(
        currentPhoto.id,
        _currentUserId,
      );
      likeCount.value = currentPhoto.likeCount;
    } catch (_) {
      // 오류 무시
    }
  }

  Future<void> _loadComments() async {
    isLoadingComments.value = true;
    try {
      // ✅ String UUID 사용
      final result = await _commentRepository.getComments(currentPhoto.id);
      comments.assignAll(result);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> toggleLike() async {
    try {
      // ✅ String UUID 사용
      await _likeLocalSource.toggleLike(
        currentPhoto.id,
        _currentUserId,
      );

      isLiked.value = !isLiked.value;
      likeCount.value += isLiked.value ? 1 : -1;
    } catch (_) {
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
      // ✅ String UUID 사용
      final comment = await _commentRepository.addComment(
        currentPhoto.id,
        text,
      );

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

    // ✅ nickname 비교
    if (comment.nickname != _currentUserNickname) {
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
      // ✅ String UUID 사용
      await _commentRepository.deleteComment(
        currentPhoto.id,
        comment.commentId,  // ✅ index → commentId
      );
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
      final success = await GallerySaver.saveImageFromUrl(
        currentPhoto.imageUrl,
      );

      if (success) {
        Get.snackbar(
          '완료',
          '갤러리에 저장되었습니다',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          '실패',
          '이미지 저장에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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