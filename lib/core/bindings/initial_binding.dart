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
import '../../data/sources/remote/real/real_album_remote_source.dart';
import '../../data/sources/remote/real/real_auth_remote_source.dart';
import '../../data/sources/remote/real/real_comment_remote_source.dart';
import '../../data/sources/remote/real/real_photo_remote_source.dart';
import '../../data/sources/remote/real/real_reaction_remote_source.dart';
import '../../data/sources/remote/real/real_user_remote_source.dart';
import '../../data/sources/remote/user_remote_source.dart';
import '../../data/repositories/guest_repository_impl.dart';
import '../../data/sources/remote/guest_remote_source.dart';
import '../../data/sources/remote/mock/mock_guest_remote_source.dart';
import '../../data/sources/remote/real/real_guest_remote_source.dart';
import '../../domain/repositories/guest_repository.dart';
import '../../domain/repositories/album_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/controllers/auth/auth_controller.dart';
import '../../presentation/controllers/auth/login_controller.dart';
import '../../presentation/controllers/auth/signup_controller.dart';
import '../../presentation/controllers/network/network_controller.dart';
import '../../presentation/controllers/user/user_controller.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

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

    Get.lazyPut<GuestRepository>(
          () => GuestRepositoryImpl(
        remoteSource: Get.find(),
        secureStorage: Get.find(),
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

    Get.lazyPut<LoginController>(
          () => LoginController(authRepository: Get.find()),
      fenix: true,
    );

    Get.lazyPut<SignupController>(
          () => SignupController(authRepository: Get.find()),
      fenix: true,
    );

    Get.lazyPut(
          () => UserController(userRepository: Get.find()),
      fenix: true,
    );
  }

  void _bindMockSources() {
    Get.put<AuthRemoteSource>(MockAuthRemoteSource(), permanent: true);
    Get.put<AlbumRemoteSource>(MockAlbumRemoteSource(), permanent: true);
    Get.put<PhotoRemoteSource>(MockPhotoRemoteSource(), permanent: true);
    Get.put<ReactionRemoteSource>(MockReactionRemoteSource(), permanent: true);
    Get.put<CommentRemoteSource>(MockCommentRemoteSource(), permanent: true);
    Get.put<UserRemoteSource>(MockUserRemoteSource(), permanent: true);
    Get.put<GuestRemoteSource>(MockGuestRemoteSource(), permanent: true);
  }

  void _bindRealSources() {
    // Phase 1 완료: Auth Real
    Get.put<AuthRemoteSource>(
      RealAuthRemoteSource(dioClient: Get.find()),
      permanent: true,
    );
    // Phase 2 완료: User Real
    Get.put<UserRemoteSource>(
      RealUserRemoteSource(dioClient: Get.find()),
      permanent: true,
    );
    // Phase 3 완료: Album Real
    Get.put<AlbumRemoteSource>(
      RealAlbumRemoteSource(
        dioClient: Get.find(),
        localStorage: Get.find<LocalStorage>(),
      ),
      permanent: true,
    );
    // Phase 4 완료: Photo Real
    Get.put<PhotoRemoteSource>(
      RealPhotoRemoteSource(dioClient: Get.find()),
      permanent: true,
    );
    // Phase 5 대기: Mock 유지
    Get.put<CommentRemoteSource>(
      RealCommentRemoteSource(dioClient: Get.find()),
      permanent: true,
    );

    Get.put<ReactionRemoteSource>(
      RealReactionRemoteSource(dioClient: Get.find()),
      permanent: true,
    );

    Get.put<GuestRemoteSource>(
      RealGuestRemoteSource(dioClient: Get.find()),
      permanent: true,
    );
  }
}