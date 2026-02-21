import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/album/album_list_controller.dart';

class QRScanView extends StatefulWidget {
  const QRScanView({super.key});

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR 스캐너
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: AppColors.main,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 250,
            ),
          ),

          // 상단 헤더
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 뒤로가기 버튼
                  IconButton(
                    onPressed: () {
                      controller?.dispose();
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
                  IconButton(
                    onPressed: () async {
                      await controller?.toggleFlash();
                      setState(() {});
                    },
                    icon: FutureBuilder<bool?>(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        final isFlashOn = snapshot.data ?? false;
                        return Icon(
                          isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 28,
                        );
                      },
                    ),
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
                      color: Colors.white.withOpacity(0.8),
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing && scanData.code != null) {
        _handleQRCode(scanData.code!);
      }
    });
  }

  void _handleQRCode(String code) async {
    if (isProcessing) return;

    setState(() => isProcessing = true);

    try {
      // QR 코드에서 초대 코드 추출
      // 예: "gachiganjik://join?code=WD2025A" → "WD2025A"
      String inviteCode = code;

      if (code.contains('code=')) {
        final uri = Uri.parse(code);
        inviteCode = uri.queryParameters['code'] ?? code;
      }

      // 앨범 입장
      await Get.find<AlbumListController>().joinAlbum(inviteCode);

      // 카메라 정지
      controller?.pauseCamera();

      // 화면 닫기
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

      setState(() => isProcessing = false);

      // 2초 후 다시 스캔 가능
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => isProcessing = false);
        }
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}