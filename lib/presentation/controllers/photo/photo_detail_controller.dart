import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/repositories/comment_repository.dart';
import '../../../data/sources/local/like_local_source.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/utils/gallery_saver.dart';

class PhotoDetailController extends GetxController {
  final CommentRepository _commentRepository;
  final LikeLocalSource _likeLocalSource;
  final List<Photo> photos;
  final int initialIndex;

  PhotoDetailController({
    required CommentRepository commentRepository,
    required LikeLocalSource likeLocalSource,
    required this.photos,
    required this.initialIndex,
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

  final commentController = TextEditingController();

  Photo get currentPhoto => photos[currentIndex.value];

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
    _loadPhotoData();
  }

  // 사진 데이터 로드 (좋아요 + 댓글)
  Future<void> _loadPhotoData() async {
    await Future.wait([
      _loadLikeStatus(),
      _loadComments(),
    ]);
  }

  // 좋아요 상태 로드
  Future<void> _loadLikeStatus() async {
    try {
      // Isar에서 로컬 좋아요 상태 확인
      isLiked.value = await _likeLocalSource.isLiked(
        currentPhoto.id,
        'user_1', // Phase 5에서 실제 userId로
      );

      // Mock에서는 서버 좋아요 수 사용
      likeCount.value = currentPhoto.likeCount;
    } catch (_) {
      // 오류 무시
    }
  }

  // 댓글 로드
  Future<void> _loadComments() async {
    isLoadingComments.value = true;
    try {
      // Mock 서버에서 댓글 조회
      // (Phase 3에서 Photo에 포함된 댓글 + 새로 추가된 댓글)
      final result = await _commentRepository.getComments(currentPhoto.id);

      // Phase 3의 기존 댓글과 병합
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
      // Isar에 로컬 저장
      await _likeLocalSource.toggleLike(
        currentPhoto.id,
        'user_1', // Phase 5에서 실제 userId로
      );

      // UI 즉시 업데이트
      isLiked.value = !isLiked.value;
      likeCount.value += isLiked.value ? 1 : -1;

      // TODO: Phase 7에서 실제 서버 API 호출 추가
    } catch (_) {
      Get.snackbar('오류', '좋아요 처리에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
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

      // 키보드 닫기
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
    // 본인 댓글만 삭제 가능 확인
    final comment = comments[index];
    if (comment.user != '나') {
      Get.snackbar(
        '알림',
        '본인의 댓글만 삭제할 수 있습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 삭제 확인
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