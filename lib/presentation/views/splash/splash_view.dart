import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/repositories/auth_repository.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();
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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            /// 🔥 로고 + 텍스트 영역
            FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo2.png',
                      width: double.infinity,
                      fit: BoxFit.contain, // 비율 유지
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      '같이간직',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'NotoSansKR',
                        color: Color(0xFFED634C),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 4),

            /// 🔥 하단 로딩 인디케이터 (요즘 스타일)
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Color(0xFFed634c),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}