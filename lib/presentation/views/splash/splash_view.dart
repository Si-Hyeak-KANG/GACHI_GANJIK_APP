import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/repositories/auth_repository.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  AnimationController? _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    final authRepository = Get.find<AuthRepository>();
    final isLoggedIn = await authRepository.isLoggedIn();

    Get.offAllNamed(isLoggedIn ? Routes.home : Routes.login);
  }

  @override
  void dispose() {
    _lottieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        color: AppColors.bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/move_logo.json',
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController!
                    ..duration = composition.duration * 1
                    ..repeat();
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'MOWA',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.main,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '소중한 순간을 함께 간직하세요.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  fontFamily: 'NotoSansKR',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}