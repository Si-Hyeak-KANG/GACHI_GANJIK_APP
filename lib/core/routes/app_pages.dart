import 'package:get/get.dart';
import '../../presentation/views/splash/splash_view.dart';
// import '../../presentation/views/auth/login_view.dart'; // Phase 1에서 생성
// import '../../presentation/views/home/home_view.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
    ),
    // Phase 1에서 추가
    // GetPage(name: Routes.login, page: () => const LoginView()),
    // GetPage(name: Routes.home, page: () => const HomeView()),
  ];
}

class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const createAlbum = '/create-album';
  static const albumDetail = '/album-detail';
  static const photoDetail = '/photo-detail';
}