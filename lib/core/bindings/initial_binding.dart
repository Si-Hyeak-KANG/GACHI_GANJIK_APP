import 'package:get/get.dart';
import '../../core/services/sync_service.dart';
import '../../data/repositories/album_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/sources/firebase/firebase_storage_source.dart';
import '../../data/sources/local/photo_local_source.dart';
import '../../data/sources/remote/album_remote_source.dart';
import '../../data/sources/remote/auth_remote_source.dart';
import '../../data/sources/remote/mock/mock_album_remote_source.dart';
import '../../data/sources/remote/mock/mock_auth_remote_source.dart';
import '../../data/sources/remote/mock/mock_photo_remote_source.dart';
import '../../data/sources/remote/mock/mock_user_remote_source.dart';
import '../../data/sources/remote/photo_remote_source.dart';
import '../../domain/repositories/album_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/controllers/auth/auth_controller.dart';
import '../../presentation/controllers/network/network_controller.dart';
import '../../presentation/controllers/user/user_controller.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Network
    Get.put(DioClient(Get.find<SecureStorage>()), permanent: true);
    Get.put(NetworkController(), permanent: true);

    // Data Sources
    Get.lazyPut<AuthRemoteSource>(() => MockAuthRemoteSource());
    Get.lazyPut<AlbumRemoteSource>(() => MockAlbumRemoteSource());
    Get.lazyPut<PhotoRemoteSource>(() => MockPhotoRemoteSource());
    Get.lazyPut<PhotoLocalSource>(() => PhotoLocalSource());
    Get.lazyPut<FirebaseStorageSource>(() => FirebaseStorageSource());

    // Repositories
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

    Get.lazyPut<PhotoRepository>(
          () => PhotoRepositoryImpl(
        remoteSource: Get.find(),
        localSource: Get.find(),
        storageSource: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<UserRepository>(
          () =>
          UserRepositoryImpl(
            remoteSource: MockUserRemoteSource(),
            storageSource: FirebaseStorageSource(),
          ),
      fenix: true,
    );

    Get.put(
      SyncService(
        albumRepository: Get.find(),
        photoRepository: Get.find(),
        photoLocalSource: Get.find(),
      ),
      permanent: true,
    );

    // Controllers
    Get.put(
      AuthController(
        authRepository: Get.find(),
      ),
      permanent: true,
    );

    Get.lazyPut(
          () => UserController(userRepository: Get.find()),
      fenix: true,
    );
  }
}