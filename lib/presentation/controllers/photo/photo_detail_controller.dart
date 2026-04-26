import 'package:flutter/material.dart';
import 'package:gachiganjik_app/domain/enum/album_role.dart';
import 'package:get/get.dart';
import '../../../core/storage/local_storage.dart';
import '../../../domain/entities/photo.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/comment_repository.dart';
import '../../../data/repositories/photo_repository_impl.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/utils/gallery_saver.dart';
import '../album/album_detail_controller.dart';
import '../album/album_list_controller.dart';
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
  static final Map<String, bool> _likeCache = {};
  final RxInt likeCount = 0.obs;
  final RxList<Comment> comments = <Comment>[].obs;
  final RxBool isLoadingComments = false.obs;
  final RxBool isAddingComment = false.obs;
  final RxBool isSavingImage = false.obs;
  final RxBool isModalExpanded = false.obs;

  final commentController = TextEditingController();
  final RxInt commentTextLength = 0.obs;

  Photo get currentPhoto => photos[currentIndex.value];
  bool get canDownload => album.albumRole.canManage;

  bool get isPhotoOwner => currentPhoto.uploaderId == _currentUserId;
  bool get canDeletePhoto => isPhotoOwner || album.albumRole.canManage;

  String get _currentUserId {
    try {
      final fromAuth = Get.find<AuthController>().currentUser.value?.userId;
      if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;
      return Get.find<LocalStorage>().getUserId() ?? '';
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

  String get currentUserNickname => _currentUserNickname;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    _loadPhotoData();
    commentController.addListener(() {
      commentTextLength.value = commentController.text.length;
    });
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
    isLiked.value = _likeCache[currentPhoto.id] ?? false;
  }

  Future<void> _loadComments() async {
    isLoadingComments.value = true;
    try {
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
    final prevLiked = isLiked.value;
    final prevCount = likeCount.value;

    isLiked.value = !prevLiked;
    likeCount.value = isLiked.value ? prevCount + 1 : prevCount - 1;

    try {
      final result = await _photoRepository.toggleLike(
        album.id,
        currentPhoto.id,
      );
      isLiked.value = result.isLiked;
      likeCount.value = result.likeCount;
      _likeCache[currentPhoto.id] = result.isLiked;
      _updateCurrentPhoto(likeCount: result.likeCount);
    } catch (_) {
      isLiked.value = prevLiked;
      likeCount.value = prevCount;
      Get.snackbar('오류', '좋아요 처리에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── 사진 삭제 ─────────────────────────────────────
  Future<void> deletePhoto() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('사진 삭제'),
        content: const Text('이 사진을 삭제하시겠어요?'),
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
      await _photoRepository.deletePhoto(
        currentPhoto.id,
        albumId: album.id,
        imageUrl: currentPhoto.imageUrl,
      );
      if (Get.isRegistered<AlbumDetailController>()) {
        await Get.find<AlbumDetailController>().fetchMoments();
      }
      _refreshAlbumList();
      Get.back();
      Get.snackbar('완료', '사진이 삭제되었습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('오류', '사진 삭제에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── 메시지 수정 ───────────────────────────────────
  Future<void> updateMessage() async {
    final textController =
    TextEditingController(text: currentPhoto.message ?? '');

    final newMessage = await Get.dialog<String>(
      AlertDialog(
        title: const Text('메시지 수정'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: '메시지를 입력하세요',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 100,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              Get.back(result: text);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      textController.dispose();
    });
    if (newMessage == null) return;

    try {
      await _photoRepository.updatePhotoMessage(
        albumId: album.id,
        photoId: currentPhoto.id,
        message: newMessage,
      );
      _updateCurrentPhoto(message: newMessage.isEmpty ? null : newMessage);
      currentIndex.refresh();
      Get.snackbar('완료', '메시지가 수정되었습니다',
          snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('오류', '메시지 수정에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    isAddingComment.value = true;
    try {
      final compositeId = '${album.id}::${currentPhoto.id}';
      await _commentRepository.addComment(compositeId, text);
      final updated = await _commentRepository.getComments(compositeId);
      comments.assignAll(updated);
      _updateCurrentPhoto(commentCount: updated.length);
      commentController.clear();
      FocusScope.of(Get.context!).unfocus();
      Get.snackbar('완료', '댓글이 추가되었습니다',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1));
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAddingComment.value = false;
    }
  }

  Future<void> deleteComment(int index) async {
    final comment = comments[index];

    if (!comment.isMine) {
      Get.snackbar('알림', '본인의 댓글만 삭제할 수 있습니다',
          snackPosition: SnackPosition.BOTTOM);
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
      _updateCurrentPhoto(commentCount: comments.length);
      Get.snackbar('완료', '댓글이 삭제되었습니다',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1));
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> saveImage() async {
    if (!canDownload) {
      Get.snackbar('권한 없음', '관리자만 사진을 다운로드할 수 있습니다',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSavingImage.value = true;
    try {
      final success =
      await GallerySaver.saveImageFromUrl(currentPhoto.imageUrl);
      Get.snackbar(
        success ? '완료' : '실패',
        success ? '갤러리에 저장되었습니다' : '이미지 저장에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        e.toString().contains('권한') ? '갤러리 접근 권한이 필요합니다' : '이미지 저장에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingImage.value = false;
    }
  }

  // ── Private ──────────────────────────────────────
  void _refreshAlbumList() {
    if (Get.isRegistered<AlbumListController>()) {
      Get.find<AlbumListController>().fetchAlbums();
    }
  }

  /// 현재 사진의 특정 필드만 업데이트 (photos 리스트 캐시 유지)
  void _updateCurrentPhoto({
    int? likeCount,
    int? commentCount,
    String? message,
  }) {
    final idx = currentIndex.value;
    final p = photos[idx];
    photos[idx] = Photo(
      id: p.id,
      albumId: p.albumId,
      imageUrl: p.imageUrl,
      thumbnailUrl: p.thumbnailUrl,
      message: message ?? p.message,
      photoDate: p.photoDate,
      uploaderId: p.uploaderId,
      uploaderNickname: p.uploaderNickname,
      uploaderProfileImageUrl: p.uploaderProfileImageUrl,
      createdAt: p.createdAt,
      likeCount: likeCount ?? p.likeCount,
      commentCount: commentCount ?? p.commentCount,
    );
  }
}