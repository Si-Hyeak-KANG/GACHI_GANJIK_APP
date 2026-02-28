import 'package:get/get.dart';
import '../../core/services/sync_service.dart';
import '../../data/repositories/album_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/sources/firebase/firebase_storage_source.dart';
import '../../data/sources/local/photo_local_source.dart';
import '../../data/sources/remote/album_remote_source.dart';
import '../../data/sources/remote/auth_remote_source.dart';
import '../../data/sources/remote/comment_remote_source.dart';
import '../../data/sources/remote/mock/mock_album_remote_source.dart';
import '../../data/sources/remote/mock/mock_auth_remote_source.dart';
import '../../data/sources/remote/mock/mock_comment_remote_source.dart';
import '../../data/sources/remote/mock/mock_photo_remote_source.dart';
import '../../data/sources/remote/mock/mock_reaction_remote_source.dart';
import '../../data/sources/remote/mock/mock_user_remote_source.dart';
import '../../data/sources/remote/photo_remote_source.dart';
import '../../data/sources/remote/reaction_remote_source.dart';
import '../../data/sources/remote/user_remote_source.dart';
import '../../domain/repositories/album_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/controllers/auth/auth_controller.dart';
import '../../presentation/controllers/network/network_controller.dart';
import '../../presentation/controllers/user/user_controller.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

// flutter run               → Mock 사용
// flutter run --dart-define=USE_REAL_API=true → Real API 사용
const bool _useRealApi = bool.fromEnvironment('USE_REAL_API', defaultValue: false);

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ── Network ──────────────────────────────────────
    Get.put(DioClient(Get.find<SecureStorage>()), permanent: true);
    Get.put(NetworkController(), permanent: true);

    // ── Data Sources ─────────────────────────────────
    if (_useRealApi) {
      _bindRealSources();
    } else {
      _bindMockSources();
    }

    Get.lazyPut<PhotoLocalSource>(() => PhotoLocalSource());
    Get.lazyPut<FirebaseStorageSource>(() => FirebaseStorageSource());

    // ── Repositories ─────────────────────────────────
    Get.lazyPut<AuthRepository>(
          () => AuthRepositoryImpl(
        remoteSource: Get.find(),
        secureStorage: Get.find(),
        localStorage: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<AlbumRepository>(
          () => AlbumRepositoryImpl(remoteSource: Get.find()),
      fenix: true,
    );

    // PhotoRepositoryImpl: 인터페이스 타입 + 구체 타입 모두 등록
    // → AlbumDetailBinding, PhotoDetailBinding에서 Get.find<PhotoRepositoryImpl>() 사용 가능
    final photoRepo = PhotoRepositoryImpl(
      remoteSource: Get.find(),
      reactionRemoteSource: Get.find(),
      localSource: Get.find(),
      storageSource: Get.find(),
    );
    Get.put<PhotoRepository>(photoRepo, permanent: true);
    Get.put<PhotoRepositoryImpl>(photoRepo, permanent: true);

    Get.lazyPut<CommentRepository>(
          () => CommentRepositoryImpl(remoteSource: Get.find()),
      fenix: true,
    );

    Get.lazyPut<UserRepository>(
          () => UserRepositoryImpl(
        remoteSource: Get.find(),
        storageSource: Get.find(),
      ),
      fenix: true,
    );

    // ── Services ─────────────────────────────────────
    Get.put(
      SyncService(
        albumRepository: Get.find(),
        photoRepository: Get.find(),
        photoLocalSource: Get.find(),
      ),
      permanent: true,
    );

    // ── Controllers ──────────────────────────────────
    Get.put(
      AuthController(authRepository: Get.find()),
      permanent: true,
    );

    Get.lazyPut(
          () => UserController(userRepository: Get.find()),
      fenix: true,
    );
  }

  void _bindMockSources() {
    // 싱글톤으로 등록 (permanent: true) → 모든 화면에서 같은 인스턴스 공유
    // Mock은 메모리 내 데이터이므로 같은 인스턴스를 써야 업로드가 목록에 반영됨
    Get.put<AuthRemoteSource>(MockAuthRemoteSource(), permanent: true);
    Get.put<AlbumRemoteSource>(MockAlbumRemoteSource(), permanent: true);
    Get.put<PhotoRemoteSource>(MockPhotoRemoteSource(), permanent: true);
    Get.put<ReactionRemoteSource>(MockReactionRemoteSource(), permanent: true);
    Get.put<CommentRemoteSource>(MockCommentRemoteSource(), permanent: true);
    Get.put<UserRemoteSource>(MockUserRemoteSource(), permanent: true);
  }

  void _bindRealSources() {
    final dio = Get.find<DioClient>();
    // Real 구현체로 교체 시 여기에 추가
    // Get.lazyPut<AuthRemoteSource>(() => RealAuthRemoteSource(dioClient: dio));
    // ...
  }
}