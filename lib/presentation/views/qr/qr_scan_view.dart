import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/album/album_list_controller.dart';

class QRScanView extends StatefulWidget {
  const QRScanView({super.key});

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  final MobileScannerController _controller = MobileScannerController();
  bool isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR 스캐너
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                _handleQRCode(barcode!.rawValue!);
              }
            },
          ),

          // 스캔 오버레이
          _ScanOverlay(),

          // 상단 헤더
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _controller.dispose();
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  // 플래시 토글
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, state, child) {
                      final isTorchOn = state.torchState == TorchState.on;
                      return IconButton(
                        onPressed: () => _controller.toggleTorch(),
                        icon: Icon(
                          isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 28,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 하단 안내 텍스트
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    'QR 코드를 스캔해주세요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '앨범의 QR 코드를 카메라에 비춰주세요',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRCode(String code) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    await _controller.stop();

    try {
      // QR 코드에서 초대 코드 추출
      // 예: "gachiganjik://join?code=WD2025A" → "WD2025A"
      String inviteCode = code;
      if (code.contains('code=')) {
        final uri = Uri.parse(code);
        inviteCode = uri.queryParameters['code'] ?? code;
      }

      await Get.find<AlbumListController>().joinAlbum(inviteCode);

      Get.back();
      Get.snackbar(
        '성공',
        '앨범에 입장했습니다',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.main,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '유효하지 않은 QR 코드입니다',
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => isProcessing = false);
        await _controller.start();
      }
    }
  }
}

// 스캔 가이드 오버레이
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const cutOutSize = 250.0;
    final cutOutTop = (size.height - cutOutSize) / 2 - 40;

    return Stack(
      children: [
        // 어두운 배경 (4방향)
        Positioned(top: 0, left: 0, right: 0, height: cutOutTop,
            child: const ColoredBox(color: Colors.black54)),
        Positioned(top: cutOutTop + cutOutSize, left: 0, right: 0, bottom: 0,
            child: const ColoredBox(color: Colors.black54)),
        Positioned(top: cutOutTop, left: 0, width: (size.width - cutOutSize) / 2, height: cutOutSize,
            child: const ColoredBox(color: Colors.black54)),
        Positioned(top: cutOutTop, right: 0, width: (size.width - cutOutSize) / 2, height: cutOutSize,
            child: const ColoredBox(color: Colors.black54)),

        // 스캔 박스 모서리
        Positioned(
          top: cutOutTop,
          left: (size.width - cutOutSize) / 2,
          child: SizedBox(
            width: cutOutSize,
            height: cutOutSize,
            child: CustomPaint(painter: _CornerPainter()),
          ),
        ),
      ],
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.main
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 30.0;
    const r = 10.0;

    // 좌상단
    canvas.drawLine(Offset(r, 0), Offset(len, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, len), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), -3.14, 3.14 / 2, false, paint);

    // 우상단
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), -3.14 / 2, 3.14 / 2, false, paint);

    // 좌하단
    canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height - r), paint);
    canvas.drawLine(Offset(r, size.height), Offset(len, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 3.14 / 2, 3.14 / 2, false, paint);

    // 우하단
    canvas.drawLine(Offset(size.width, size.height - len), Offset(size.width, size.height - r), paint);
    canvas.drawLine(Offset(size.width - len, size.height), Offset(size.width - r, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, 3.14 / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}