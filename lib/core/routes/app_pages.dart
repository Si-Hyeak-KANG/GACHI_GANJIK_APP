import 'package:get/get.dart';

import '../../core/bindings/album_detail_binding.dart';
import '../../core/bindings/create_album_binding.dart';
import '../../core/bindings/edit_profile_binding.dart';
import '../../core/bindings/home_binding.dart';
import '../../core/bindings/login_binding.dart';
import '../../core/bindings/photo_detail_binding.dart';
import '../../core/bindings/settings_binding.dart';
import '../../core/bindings/signup_binding.dart';
import '../../presentation/views/album/album_detail_view.dart';
import '../../presentation/views/album/create_album_view.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/signup_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/photo/photo_detail_view.dart';
import '../../presentation/views/settings/settings_view.dart';
import '../../presentation/views/splash/splash_view.dart';
import '../../presentation/views/user/edit_profile_view.dart';

class AppPages {
  static const initial = Routes.splash;

  static const defaultTransition = Transition.cupertino;
  static const transitionDuration = Duration(milliseconds: 300);

  static const modalTransition = Transition.downToUp;
  static const fadeTransition = Transition.fade;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      transition: fadeTransition,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: modalTransition,
      transitionDuration: transitionDuration,
    ),

    GetPage(
      name: Routes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
      transition: defaultTransition,
      transitionDuration: transitionDuration,
    ),

    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: defaultTransition,
      transitionDuration: transitionDuration,
    ),

    GetPage(
      name: Routes.createAlbum,
      page: () => const CreateAlbumView(),
      binding: CreateAlbumBinding(),
      transition: defaultTransition,
      transitionDuration: transitionDuration,
    ),

    GetPage(
      name: Routes.albumDetail,
      page: () => const AlbumDetailView(),
      binding: AlbumDetailBinding(),
      transition: defaultTransition,
      transitionDuration: transitionDuration,
    ),

    GetPage(
      name: Routes.photoDetail,
      page: () => const PhotoDetailView(),
      binding: PhotoDetailBinding(),
      // Hero 애니메이션이 주 전환 — 라우트 자체는 fade로 처리해야 자연스러움
      // zoom을 쓰면 Hero와 충돌하여 어색한 이중 애니메이션 발생
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 280),
    ),

    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
      transition: defaultTransition,
      transitionDuration: transitionDuration,
    ),

    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: defaultTransition,
      transitionDuration: transitionDuration,
    ),
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
  static const editProfile = '/edit-profile';
  static const settings = '/settings';
}