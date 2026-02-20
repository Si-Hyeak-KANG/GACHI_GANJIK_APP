import 'package:get/get.dart';
import '../../core/bindings/album_detail_binding.dart';
import '../../core/bindings/create_album_binding.dart';
import '../../core/bindings/home_binding.dart';
import '../../core/bindings/login_binding.dart';
import '../../core/bindings/photo_detail_binding.dart';
import '../../core/bindings/signup_binding.dart';
import '../../presentation/views/album/album_detail_view.dart';
import '../../presentation/views/album/create_album_view.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/signup_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/photo/photo_detail_view.dart';
import '../../presentation/views/splash/splash_view.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.createAlbum,
      page: () => const CreateAlbumView(),
      binding: CreateAlbumBinding(),
    ),
    GetPage(
      name: Routes.albumDetail,
      page: () => const AlbumDetailView(),
      binding: AlbumDetailBinding(),
    ),
    GetPage(
      name: Routes.photoDetail,
      page: () => const PhotoDetailView(),
      binding: PhotoDetailBinding(),
    )
  ];
}

class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const createAlbum = '/create-album';
  static const albumDetail = '/album-detail';
  static const photoDetail = '/photo-detail';
}