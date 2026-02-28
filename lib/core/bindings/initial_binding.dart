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
import '../../data/sources/remote/guest_remote_source.dart';
import '../../data/sources/remote/photo_remote_source.dart';
import '../../data/sources/remote/reaction_remote_source.dart';
import '../../data/sources/remote/user_remote_source.dart';
import '../../data/sources/remote/mock/mock_album_remote_source.dart';
import '../../data/sources/remote/mock/mock_auth_remote_source.dart';
import '../../data/sources/remote/mock/mock_comment_remote_source.dart';
import '../../data/sources/remote/mock/mock_photo_remote_source.dart';
import '../../data/sources/remote/mock/mock_reaction_remote_source.dart';
import '../../data/sources/remote/mock/mock_user_remote_source.dart';
import '../../data/sources/remote/real/real_album_remote_source.dart';
import '../../data/sources/remote/real/real_auth_remote_source.dart';
import '../../data/sources/remote/real/real_comment_remote_source.dart';
import '../../data/sources/remote/real/real_photo_remote_source.dart';
import '../../data/sources/remote/real/real_reaction_remote_source.dart';
import '../../data/sources/remote/real/real_guest_remote_source.dart';
import '../../data/sources/remote/real/real_user_remote_source.dart';
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

/// flutter run                         → Mock 사용
/// flutter run --dart-define=USE_REAL_API=true → 실제 API 사용
const bool _useRealApi = bool.fromEnvironment('USE_REAL_API', defaultValue: false);

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ===================== Network =====================
    Get.put(DioClient(Get.find<SecureStorage>()), permanent: true);
    Get.put(NetworkController(), permanent: true);

    // ===================== Remote Sources =====================
    if (_useRealApi) {
      _bindRealSources();
    } else {
      _bindMockSources();
    }

    // ===================== Local Sources =====================
    Get.lazyPut<PhotoLocalSource>(() => PhotoLocalSource());
    Get.lazyPut<FirebaseStorageSource>(() => FirebaseStorageSource());

    // ===================== Repositories =====================
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

    // PhotoRepositoryImpl을 구체 타입으로도 등록 (toggleLike 접근용)
    Get.lazyPut<PhotoRepositoryImpl>(
          () => PhotoRepositoryImpl(
        remoteSource: Get.find(),
        reactionRemoteSource: Get.find(),
        localSource: Get.find(),
        storageSource: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut<PhotoRepository>(
          () => Get.find<PhotoRepositoryImpl>(),
      fenix: true,
    );

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

    // ===================== Services =====================
    Get.put(
      SyncService(
        albumRepository: Get.find(),
        photoRepository: Get.find(),
        photoLocalSource: Get.find(),
      ),
      permanent: true,
    );

    // ===================== Controllers =====================
    Get.put(
      AuthController(authRepository: Get.find()),
      permanent: true,
    );

    Get.lazyPut(
          () => UserController(userRepository: Get.find()),
      fenix: true,
    );
  }

  void _bindRealSources() {
    Get.lazyPut<AuthRemoteSource>(
          () => RealAuthRemoteSource(dioClient: Get.find()),
    );
    Get.lazyPut<AlbumRemoteSource>(
          () => RealAlbumRemoteSource(dioClient: Get.find()),
    );
    Get.lazyPut<PhotoRemoteSource>(
          () => RealPhotoRemoteSource(dioClient: Get.find()),
    );
    Get.lazyPut<CommentRemoteSource>(
          () => RealCommentRemoteSource(dioClient: Get.find()),
    );
    Get.lazyPut<ReactionRemoteSource>(
          () => RealReactionRemoteSource(dioClient: Get.find()),
    );
    Get.lazyPut<GuestRemoteSource>(
          () => RealGuestRemoteSource(dioClient: Get.find()),
    );
    Get.lazyPut<UserRemoteSource>(
          () => RealUserRemoteSource(dioClient: Get.find()),
    );
  }

  void _bindMockSources() {
    Get.lazyPut<AuthRemoteSource>(() => MockAuthRemoteSource());
    Get.lazyPut<AlbumRemoteSource>(() => MockAlbumRemoteSource());
    Get.lazyPut<PhotoRemoteSource>(() => MockPhotoRemoteSource());
    Get.lazyPut<CommentRemoteSource>(() => MockCommentRemoteSource());
    Get.lazyPut<ReactionRemoteSource>(() => MockReactionRemoteSource());
    Get.lazyPut<UserRemoteSource>(() => MockUserRemoteSource());
  }
}