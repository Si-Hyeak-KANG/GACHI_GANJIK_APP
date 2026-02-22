import 'package:flutter/material.dart';
import 'package:gachiganjik_app/domain/enum/album_role.dart';
import 'package:get/get.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/entities/album.dart';  // ✅ 추가
import '../../../domain/repositories/comment_repository.dart';
import '../../../data/sources/local/like_local_source.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/utils/gallery_saver.dart';

class PhotoDetailController extends GetxController {
  final CommentRepository _commentRepository;
  final LikeLocalSource _likeLocalSource;
  final List<Photo> photos;
  final int initialIndex;
  final Album album;  // ✅ 추가: 권한 체크용

  PhotoDetailController({
    required CommentRepository commentRepository,
    required LikeLocalSource likeLocalSource,
    required this.photos,
    required this.initialIndex,
    required this.album,  // ✅ 추가
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

  // ✅ 추가: 모달 상태
  final RxBool isModalExpanded = false.obs;

  final commentController = TextEditingController();

  Photo get currentPhoto => photos[currentIndex.value];

  // ✅ 추가: 관리자 권한 체크
  bool get canDownload => album.role.canManage;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);

    // 현재 사진 데이터 로드
    _loadPhotoData();
  }

  @override
  void onClose() {
    pageController.dispose();
    commentController.dispose();
    super.onClose();
  }

  // 페이지 변경 시
  void onPageChanged(int index) {
    currentIndex.value = index;

    // ✅ 추가: 사진 전환 시 모달 닫기
    if (isModalExpanded.value) {
      isModalExpanded.value = false;
    }

    _loadPhotoData();
  }

  // ✅ 추가: 모달 열기
  void expandModal() {
    isModalExpanded.value = true;

    // 댓글 로드 (아직 안 했다면)
    if (comments.isEmpty && !isLoadingComments.value) {
      _loadComments();
    }
  }

  // ✅ 추가: 모달 닫기
  void collapseModal() {
    isModalExpanded.value = false;

    // 키보드 닫기
    FocusScope.of(Get.context!).unfocus();
  }

  // 사진 데이터 로드 (좋아요만 - 댓글은 모달 열 때)
  Future<void> _loadPhotoData() async {
    await _loadLikeStatus();
  }

  // 좋아요 상태 로드
  Future<void> _loadLikeStatus() async {
    try {
      isLiked.value = await _likeLocalSource.isLiked(
        currentPhoto.id,
        'user_1',
      );
      likeCount.value = currentPhoto.likeCount;
    } catch (_) {
      // 오류 무시
    }
  }

  // 댓글 로드
  Future<void> _loadComments() async {
    isLoadingComments.value = true;
    try {
      final result = await _commentRepository.getComments(currentPhoto.id);
      final allComments = [...currentPhoto.comments, ...result];
      comments.assignAll(allComments);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingComments.value = false;
    }
  }

  // 좋아요 토글
  Future<void> toggleLike() async {
    try {
      await _likeLocalSource.toggleLike(
        currentPhoto.id,
        'user_1',
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

  // 댓글 추가
  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    isAddingComment.value = true;
    try {
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

  // 댓글 삭제
  Future<void> deleteComment(int index) async {
    final comment = comments[index];
    if (comment.user != '나') {
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
      await _commentRepository.deleteComment(currentPhoto.id, index);
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

  // 이미지 저장
  Future<void> saveImage() async {
    // ✅ 추가: 권한 체크
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