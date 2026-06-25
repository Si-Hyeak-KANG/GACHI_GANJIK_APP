import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/auth/guest_entry_controller.dart';

class GuestEntryView extends StatelessWidget {
  const GuestEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GuestEntryController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Obx(() {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
                  child: child,
                ),
              );
            },
            child: switch (c.currentStep.value) {
              GuestEntryStep.albumEntry => const _AlbumEntryStep(
                key: ValueKey('albumEntry'),
              ),
              GuestEntryStep.nickname => const _NicknameStep(
                key: ValueKey('nickname'),
              ),
            },
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 공통 레이아웃
// ─────────────────────────────────────────────────────────────

class _StepLayout extends StatelessWidget {
  const _StepLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.textPrimary, size: 20),
            onPressed: Get.back,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: child,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 1 - 앨범 입장
// ─────────────────────────────────────────────────────────────

class _AlbumEntryStep extends StatelessWidget {
  const _AlbumEntryStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GuestEntryController>();

    return Obx(() {
      // QR 스캔 모드
      if (c.isQrMode.value) {
        return _QrScanView(
          onDetected: c.onQrDetected,
          onClose: c.toggleQrMode,
          error: c.qrError.value,
        );
      }

      // 코드 입력 모드
      return _StepLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 64),
            const Text(
              '앨범에 입장해요',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '앨범 코드를 입력하거나 QR을 스캔하세요',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),

            // QR 스캔 버튼
            GestureDetector(
              onTap: c.toggleQrMode,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.mainLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.main.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded,
                        size: 40, color: AppColors.main),
                    SizedBox(height: 8),
                    Text(
                      'QR 코드 스캔',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.main,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 구분선
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.divider)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '또는',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.divider)),
              ],
            ),

            const SizedBox(height: 24),

            // 코드 입력
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '앨범 코드',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.inviteCodeController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: '앨범 코드 입력',
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: AppColors.inactive,
                      letterSpacing: 0,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: AppColors.main, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Obx(() {
              if (c.errorMessage.value.isEmpty) return const SizedBox.shrink();
              return Text(
                c.errorMessage.value,
                style: const TextStyle(fontSize: 13, color: AppColors.error),
              );
            }),

            const SizedBox(height: 32),

            // 입장하기 버튼
            Obx(() {
              final hasCode = c.inviteCodeText.value.trim().isNotEmpty;
              return SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  onPressed: hasCode ? c.confirmInviteCode : null,
                  style: TextButton.styleFrom(
                    backgroundColor:
                    hasCode ? AppColors.main : AppColors.inactive,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '입장하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// QR 스캔 뷰
// ─────────────────────────────────────────────────────────────

class _QrScanView extends StatefulWidget {
  const _QrScanView({
    required this.onDetected,
    required this.onClose,
    required this.error,
  });

  final void Function(String) onDetected;
  final VoidCallback onClose;
  final String error;

  @override
  State<_QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<_QrScanView> {
  late final MobileScannerController _scannerController;
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            if (_detected) return;
            final barcode = capture.barcodes.firstOrNull;
            if (barcode?.rawValue != null) {
              _detected = true;
              widget.onDetected(barcode!.rawValue!);
            }
          },
        ),

        // 상단 닫기
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: widget.onClose,
            ),
          ),
        ),

        // 스캔 가이드 오버레이
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.main, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.error.isNotEmpty ? widget.error : 'QR 코드를 네모 안에 맞춰주세요',
                  style: TextStyle(
                    color: widget.error.isNotEmpty ? Colors.redAccent : Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 2 - 닉네임 입력
// ─────────────────────────────────────────────────────────────

class _NicknameStep extends StatelessWidget {
  const _NicknameStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GuestEntryController>();

    return _StepLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          const Text(
            '어떻게 불러드릴까요?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '앨범에서 사용할 이름을 입력해주세요',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '이름',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: c.nicknameController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '2자 이상 20자 이하',
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: AppColors.inactive,
                  ),
                  filled: true,
                  fillColor: AppColors.cardBg,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: AppColors.main, width: 1.5),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Obx(() {
            if (c.nicknameError.value.isEmpty) return const SizedBox.shrink();
            return Text(
              c.nicknameError.value,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            );
          }),

          const SizedBox(height: 32),

          Obx(() => SizedBox(
            width: double.infinity,
            height: 54,
            child: TextButton(
              onPressed: c.isLoading.value ? null : c.confirmNicknameAndJoin,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.main,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: c.isLoading.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                '앨범 입장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}