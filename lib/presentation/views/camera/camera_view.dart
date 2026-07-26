import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart' as cam;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/camera/camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        child: switch (controller.step.value) {
          CameraStep.shooting => _ShootingStep(
              key: const ValueKey('shooting')),
          CameraStep.review => _ReviewStep(
              key: const ValueKey('review')),
          CameraStep.albumSelect => _AlbumSelectStep(
              key: const ValueKey('albumSelect')),
          CameraStep.comment => _CommentStep(
              key: const ValueKey('comment')),
          CameraStep.complete => _CompleteStep(
              key: const ValueKey('complete')),
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 1 - 촬영본 확인 (스택 브라우징 · 스와이프 삭제)
// ─────────────────────────────────────────────────────────────

enum _DragLock { none, horizontal, up, down }

class _ShootingStep extends StatefulWidget {
  const _ShootingStep({super.key});

  @override
  State<_ShootingStep> createState() => _ShootingStepState();
}

class _ShootingStepState extends State<_ShootingStep>
    with SingleTickerProviderStateMixin {
  final CameraController controller = Get.find();

  int _idx = 0; // 현재 보여지는 사진 인덱스
  double _dx = 0;
  double _dy = 0;
  double _rawDx = 0;
  double _rawDy = 0;
  _DragLock _lock = _DragLock.none;
  bool _busy = false;

  late AnimationController _anim;
  Animation<Offset>? _release;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _resetDrag() {
    setState(() {
      _dx = 0;
      _dy = 0;
      _rawDx = 0;
      _rawDy = 0;
      _lock = _DragLock.none;
    });
  }

  void _onFly() {
    setState(() {
      _dx = _release!.value.dx;
      _dy = _release!.value.dy;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_busy) return;
    _rawDx += d.delta.dx;
    _rawDy += d.delta.dy;

    // 첫 유의미한 움직임에서 방향(좌우 · 위 · 아래)을 하나로 고정
    if (_lock == _DragLock.none) {
      if (_rawDx.abs() < 6 && _rawDy.abs() < 6) return;
      if (_rawDx.abs() > _rawDy.abs()) {
        _lock = _DragLock.horizontal;
      } else if (_rawDy < 0) {
        _lock = _DragLock.up;
      } else {
        _lock = _DragLock.down; // 아래로는 동작·이동 없음
      }
    }

    setState(() {
      switch (_lock) {
        case _DragLock.horizontal:
          _dx = _rawDx;
          _dy = 0;
          break;
        case _DragLock.up:
          _dx = 0;
          _dy = _rawDy < 0 ? _rawDy : 0; // 위로만
          break;
        case _DragLock.down:
        case _DragLock.none:
          _dx = 0;
          _dy = 0;
          break;
      }
    });
  }

  Future<void> _onPanEnd(DragEndDetails d) async {
    if (_busy) return;
    final w = MediaQuery.of(context).size.width;
    final hThreshold = w * 0.35;
    const vThreshold = 110.0;
    final n = controller.capturedImages.length;

    // 좌/우로 임계 초과 → 삭제
    if (_lock == _DragLock.horizontal && _dx.abs() >= hThreshold) {
      await _flyOutAndDelete();
      return;
    }
    // 위로 임계 초과 → 다음 사진 (삭제 X)
    if (_lock == _DragLock.up && (-_dy) >= vThreshold && n > 1) {
      _nextPhoto();
      _resetDrag();
      return;
    }
    // 그 외 → 복귀
    _snapBack();
  }

  Future<void> _flyOutAndDelete() async {
    _busy = true;
    final w = MediaQuery.of(context).size.width;
    final begin = Offset(_dx, _dy);
    final end = Offset(_dx > 0 ? w * 1.5 : -w * 1.5, _dy);
    _release = Tween(begin: begin, end: end)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeIn));
    _anim.reset();
    _release!.addListener(_onFly);
    await _anim.forward();
    _release!.removeListener(_onFly);

    controller.deletePhotoAt(_idx);
    final n = controller.capturedImages.length;
    _idx = n > 0 ? n - 1 : 0; // 삭제 후 최신 사진 표시
    _busy = false;
    _resetDrag();
  }

  void _snapBack() {
    _busy = true;
    final begin = Offset(_dx, _dy);
    _release = Tween(begin: begin, end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.reset();
    _release!.addListener(_onFly);
    _anim.forward().whenComplete(() {
      _release!.removeListener(_onFly);
      _busy = false;
      _resetDrag();
    });
  }

  void _nextPhoto() {
    final n = controller.capturedImages.length;
    if (n <= 1) return;
    setState(() {
      _idx = (_idx - 1 + n) % n; // 순환하며 다음(더 이전) 사진
    });
  }

  Future<void> _openCamera() async {
    await Get.to(
          () => const _LiveCameraScreen(),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
    // 복귀 시 방금 찍은 최신 사진부터 표시
    if (mounted) {
      setState(() {
        final n = controller.capturedImages.length;
        _idx = n > 0 ? n - 1 : 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  const Spacer(),
                  Column(
                    children: [
                      const Text(
                        '사진 촬영',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        '${controller.capturedImages.length}장의 사진 촬영됨',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      )),
                    ],
                  ),
                  const Spacer(),
                  Obx(() {
                    if (controller.capturedImages.isEmpty) {
                      return const SizedBox(width: 48);
                    }
                    return TextButton(
                      onPressed: controller.finishShooting,
                      child: const Text(
                        '다음',
                        style: TextStyle(
                          color: AppColors.main,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // 사진 카드 (스택) or 빈 화면
            Expanded(
              child: Obx(() {
                final imgs = controller.capturedImages;
                if (imgs.isEmpty) {
                  return _emptyState();
                }

                final n = imgs.length;
                final idx = _idx.clamp(0, n - 1);
                final w = MediaQuery.of(context).size.width;
                final isDelete = _lock == _DragLock.horizontal;
                final over = isDelete
                    ? _dx.abs() >= w * 0.35
                    : (-_dy) >= 110;

                return GestureDetector(
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Stack(
                    children: [
                      if (_lock == _DragLock.horizontal ||
                          _lock == _DragLock.up)
                        _dragHint(isDelete: isDelete, over: over),
                      Transform(
                        transform: Matrix4.identity()
                          ..translate(_dx, _dy)
                          ..rotateZ(_dx / 1200),
                        alignment: Alignment.center,
                        child: _NativeRatioImage(
                          file: imgs[idx],
                          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          borderRadius: 16,
                          label: '${idx + 1} / $n',
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // 안내 힌트
            Obx(() {
              if (controller.capturedImages.isEmpty) {
                return const SizedBox(height: 12);
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.swipe_rounded,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '좌우로 밀면 삭제 · 위로 밀면 다음 사진',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // 셔터(카메라 열기) · 전체삭제
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 40),
              child: Obx(() {
                final hasPhotos = controller.capturedImages.isNotEmpty;
                return Row(
                  children: [
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 90,
                      child: hasPhotos
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: _clearAllButton(),
                      )
                          : const SizedBox.shrink(),
                    ),
                    const Spacer(),
                    _shutterButton(),
                    const Spacer(),
                    const SizedBox(width: 90),
                    const SizedBox(width: 20),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined,
                size: 40, color: AppColors.inactive),
            SizedBox(height: 14),
            Text(
              '셔터를 클릭하여 촬영하세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dragHint({required bool isDelete, required bool over}) {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: isDelete
              ? AppColors.error.withOpacity(over ? 0.15 : 0.06)
              : AppColors.main.withOpacity(over ? 0.14 : 0.07),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDelete
                    ? Icons.delete_outline
                    : Icons.keyboard_arrow_up_rounded,
                size: 42,
                color: isDelete ? AppColors.error : AppColors.main,
              ),
              const SizedBox(height: 12),
              Text(
                isDelete
                    ? (over ? '손을 놓으면 삭제됩니다' : '밀어서 삭제')
                    : (over ? '손을 놓으면 다음 사진' : '위로 밀어 다음 사진'),
                style: TextStyle(
                  color: isDelete ? AppColors.error : AppColors.main,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shutterButton() {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: _openCamera,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.main,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _clearAllButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => Get.dialog(
        AlertDialog(
          title: const Text('전체 삭제'),
          content: const Text('촬영한 사진을 모두 삭제할까요?'),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('취소')),
            TextButton(
              onPressed: () {
                Get.back();
                controller.clearAllPhotos();
                setState(() => _idx = 0);
              },
              child: const Text('삭제', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_clear_rounded,
                size: 16, color: AppColors.error.withOpacity(.85)),
            const SizedBox(width: 5),
            Text(
              '전체삭제',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 라이브 카메라 화면 (연속 촬영)
// ─────────────────────────────────────────────────────────────

class _LiveCameraScreen extends StatefulWidget {
  const _LiveCameraScreen();

  @override
  State<_LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<_LiveCameraScreen>
    with WidgetsBindingObserver {
  final CameraController controller = Get.find();

  cam.CameraController? _cam;
  bool _initializing = false;
  bool _capturing = false;
  String? _error;

  // 기기 물리적 방향 감지 → 촬영 방향에만 반영 (UI는 세로 고정)
  final _orientationCommunicator = NativeDeviceOrientationCommunicator();
  StreamSubscription<NativeDeviceOrientation>? _orientationSub;
  DeviceOrientation _captureOrientation = DeviceOrientation.portraitUp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenOrientation();
    _initCamera();
  }

  @override
  void dispose() {
    _orientationSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _cam?.dispose();
    super.dispose();
  }

  void _listenOrientation() {
    // 촬영 방향만 추적 (프리뷰는 회전시키지 않고, 촬영 후 파일을 직접 회전)
    _orientationSub = _orientationCommunicator
        .onOrientationChanged(useSensor: true)
        .listen((native) {
      final orientation = _toDeviceOrientation(native);
      if (orientation == null) return;
      _captureOrientation = orientation;
    });
  }

  // 가로 방향이 180° 뒤집혀 저장되면 landscapeLeft/Right 반환값을 서로 바꾼다.
  DeviceOrientation? _toDeviceOrientation(NativeDeviceOrientation o) {
    switch (o) {
      case NativeDeviceOrientation.portraitUp:
        return DeviceOrientation.portraitUp;
      case NativeDeviceOrientation.portraitDown:
        return DeviceOrientation.portraitDown;
      case NativeDeviceOrientation.landscapeLeft:
        return DeviceOrientation.landscapeLeft;
      case NativeDeviceOrientation.landscapeRight:
        return DeviceOrientation.landscapeRight;
      case NativeDeviceOrientation.unknown:
        return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camCtrl = _cam;
    if (camCtrl == null || !camCtrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      camCtrl.dispose();
      _cam = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_initializing) return;
    _initializing = true;
    try {
      final cameras = await cam.availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _error = '사용 가능한 카메라가 없습니다');
        return;
      }
      final back = cameras.firstWhere(
            (c) => c.lensDirection == cam.CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final camCtrl = cam.CameraController(
        back,
        cam.ResolutionPreset.high,
        enableAudio: false,
      );
      await camCtrl.initialize();
      if (!mounted) {
        camCtrl.dispose();
        return;
      }
      setState(() {
        _cam = camCtrl;
        _error = null;
      });
    } on cam.CameraException {
      if (mounted) setState(() => _error = '카메라 권한을 확인해주세요');
    } finally {
      _initializing = false;
    }
  }

  Future<void> _capture() async {
    final camCtrl = _cam;
    if (camCtrl == null || !camCtrl.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    try {
      HapticFeedback.lightImpact();
      final shot = await camCtrl.takePicture();
      // 촬영본을 기기 물리 방향에 맞춰 회전 (프리뷰는 세로 고정 유지)
      final turns = _quarterTurnsFor(_captureOrientation);
      if (turns != 0) {
        await compute(_rotateJpegFile, <Object>[shot.path, turns]);
      }
      controller.addPhoto(File(shot.path));
    } catch (_) {
      Get.snackbar('오류', '촬영에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  // 저장 사진이 반대로 돌면 landscapeLeft/Right 값을 서로 바꾸세요.
  int _quarterTurnsFor(DeviceOrientation o) {
    switch (o) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 3; // 270°
      case DeviceOrientation.portraitDown:
        return 2; // 180°
      case DeviceOrientation.landscapeRight:
        return 1; // 90°
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildPreview()),

          // 상단 닫기
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 26),
              onPressed: Get.back,
            ),
          ),

          // 하단: 썸네일(좌) · 촬영(중앙) · 완료(우)
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Row(
              children: [
                SizedBox(
                  width: 88,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _thumbnailStack(),
                  ),
                ),
                const Spacer(),
                _captureButton(),
                const Spacer(),
                SizedBox(
                  width: 88,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _doneButton(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined,
                  color: Colors.white70, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    final camCtrl = _cam;
    if (camCtrl == null || !camCtrl.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.main),
      );
    }
    // 비율 왜곡 없이 화면을 꽉 채우는(cover) 프리뷰
    final mediaSize = MediaQuery.of(context).size;
    var scale = mediaSize.aspectRatio * camCtrl.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: Center(
          child: cam.CameraPreview(camCtrl),
        ),
      ),
    );
  }

  Widget _captureButton() {
    return GestureDetector(
      onTap: _capture,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.25),
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: _capturing
              ? const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbnailStack() {
    return Obx(() {
      final imgs = controller.capturedImages;
      if (imgs.isEmpty) return const SizedBox(width: 56, height: 56);
      return SizedBox(
        width: 60,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imgs.last,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints:
                const BoxConstraints(minWidth: 22, minHeight: 22),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.main,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '${imgs.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _doneButton() {
    return GestureDetector(
      onTap: Get.back,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.main,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          '완료',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// 촬영본을 quarterTurns(×90°)만큼 회전해 저장 (isolate에서 실행)
Future<void> _rotateJpegFile(List<Object> args) async {
  final path = args[0] as String;
  final quarterTurns = args[1] as int;
  final file = File(path);
  final decoded = img.decodeImage(await file.readAsBytes());
  if (decoded == null) return;
  final rotated = img.copyRotate(decoded, angle: quarterTurns * 90);
  await file.writeAsBytes(img.encodeJpg(rotated, quality: 92));
}

// ─────────────────────────────────────────
// 원본 비율 이미지 위젯
// ─────────────────────────────────────────

class _NativeRatioImage extends StatefulWidget {
  final File file;
  final EdgeInsets margin;
  final double borderRadius;
  final String? label;

  const _NativeRatioImage({
    required this.file,
    required this.margin,
    required this.borderRadius,
    this.label,
  });

  @override
  State<_NativeRatioImage> createState() => _NativeRatioImageState();
}

class _NativeRatioImageState extends State<_NativeRatioImage> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _loadRatio();
  }

  @override
  void didUpdateWidget(_NativeRatioImage old) {
    super.didUpdateWidget(old);
    if (old.file.path != widget.file.path) _loadRatio();
  }

  Future<void> _loadRatio() async {
    final bytes = await widget.file.readAsBytes();
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final w = frame.image.width.toDouble();
    final h = frame.image.height.toDouble();
    if (mounted) setState(() => _aspectRatio = w / h);
  }

  @override
  Widget build(BuildContext context) {
    if (_aspectRatio == null) {
      return Container(
        margin: widget.margin,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.main),
        ),
      );
    }

    return Padding(
      padding: widget.margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ratio = _aspectRatio!;
          // 가로를 먼저 꽉 채우고, 세로가 넘칠 때만 축소
          double w = constraints.maxWidth;
          double h = w / ratio;
          if (h.isFinite &&
              constraints.maxHeight.isFinite &&
              h > constraints.maxHeight) {
            h = constraints.maxHeight;
            w = h * ratio;
          }
          return Center(
            child: SizedBox(
              width: w,
              height: h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(widget.file, fit: BoxFit.cover),
                    if (widget.label != null)
                      Positioned(
                        left: 14,
                        bottom: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.label!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 2 - 사진 확인 & 셀렉
// ─────────────────────────────────────────────────────────────

class _ReviewStep extends GetView<CameraController> {
  const _ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 20, color: AppColors.textPrimary),
                    onPressed: () =>
                    controller.step.value = CameraStep.shooting,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                  Obx(() => Column(
                    children: [

                      const Text(
                        "사진 선택",
                        style: TextStyle(
                          fontSize:22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height:6),

                      Text(
                        "${controller.selectedIndices.length} / ${controller.capturedImages.length} 선택",
                        style: const TextStyle(
                          fontSize:14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.goToAlbumSelect,
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        color: AppColors.main,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 사진 그리드
            Expanded(
              child: Obx(() => GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controller.capturedImages.length,
                itemBuilder: (_, index) {
                  return Obx(() {
                    final isSelected =
                    controller.selectedIndices.contains(index);
                    return GestureDetector(
                      onTap: () => controller.toggleSelect(index),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [

                          AnimatedScale(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            scale: isSelected ? 0.95 : 1,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.main
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.file(
                                  controller.capturedImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // 체크 뱃지
                          Positioned(
                            top: 6,
                            right: 6,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.main
                                    : Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
                              ),
                              child: isSelected
                                  ? Center(
                                child: Text(
                                  '${controller.selectedIndices.indexOf(index) + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                },
              )),
            ),


            // 하단 버튼
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: controller.aiSelect,
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('AI 셀렉'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.main,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.main),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final allSelected = controller.isAllSelected;
                      return OutlinedButton.icon(
                        onPressed: controller.toggleSelectAll,
                        icon: Icon(
                          allSelected
                              ? Icons.remove_done_rounded
                              : Icons.check_circle_outline,
                          size: 18,
                        ),
                        label: Text(allSelected ? '전체 해제' : '전체 선택'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 3 - 앨범 선택
// ─────────────────────────────────────────────────────────────

class _AlbumSelectStep extends GetView<CameraController> {
  const _AlbumSelectStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 20, color: AppColors.textPrimary),
                    onPressed: () =>
                    controller.step.value = CameraStep.review,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: const Text(
                '어디에 간직할까요?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // 앨범 목록 (AlbumListController.albums 변화에 반응)
            Expanded(
              child: Obx(() {
                final albums = controller.sortedAlbums();
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (albums.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          '최근 사용',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...albums.map((album) {
                        return Obx(() {
                          final isSelected =
                              controller.selectedAlbum.value?.id == album.id;
                          return GestureDetector(
                            onTap: () => controller.selectAlbum(album),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.main
                                      : AppColors.divider,
                                  width: isSelected ? 2.2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.04),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // 썸네일
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: album.coverImageUrl != null &&
                                        album.coverImageUrl!.isNotEmpty
                                        ? Image.network(
                                      album.coverImageUrl!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _defaultThumb(),
                                    )
                                        : _defaultThumb(),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          album.title,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${album.memberCount}명 · ${album.photoCount}장',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        color: AppColors.main,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    )
                                  else
                                    AnimatedOpacity(
                                      opacity: 0,
                                      duration: const Duration(milliseconds: 180),
                                      child: SizedBox(
                                        width: 34,
                                        height: 34,
                                      ),
                                    )
                                ],
                              ),
                            ),
                          );
                        });
                      }),
                      const SizedBox(height: 16),
                      const SizedBox(height: 10),
                    ],

                    // 새 앨범 만들기
                    GestureDetector(
                      onTap: () => controller.createNewAlbum(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mainLight,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.main.withOpacity(.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.03),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add_rounded,
                                color: AppColors.main, size: 24),
                            SizedBox(width: 18),
                            Text(
                              '새 앨범 만들기',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              }),
            ),

            // 다음 버튼 (코멘트 작성으로 이동)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Obx(() {
                final count = controller.selectedIndices.length;
                final hasAlbum = controller.selectedAlbum.value != null;
                return SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: hasAlbum ? controller.goToComment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.main,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.inactive,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '다음 ($count장)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultThumb() => Container(
    width: 64,
    height: 64,
    color: AppColors.cardBg,
    child: const Icon(Icons.photo_album_outlined,
        color: AppColors.inactive, size: 24),
  );
}

// ─────────────────────────────────────────────────────────────
// STEP 3.5 - 한줄 추억 코멘트
// ─────────────────────────────────────────────────────────────

class _CommentStep extends GetView<CameraController> {
  const _CommentStep({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = List<int>.from(controller.selectedIndices)..sort();
    final files = selected.map((i) => controller.capturedImages[i]).toList();
    final album = controller.selectedAlbum.value;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 20, color: AppColors.textPrimary),
                        onPressed: () =>
                        controller.step.value = CameraStep.albumSelect,
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 6),
                  child: Text(
                    '이 순간, 한 줄로 남겨요',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (album != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_album_outlined,
                            size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${album.title}에 저장',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // 선택 사진 미리보기
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: files.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        files[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 한줄 코멘트 입력 (선택)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: controller.commentController,
                      maxLength: 50,
                      minLines: 1,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        hintText: '이 순간을 한 줄로 남겨보세요 (선택)',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                        counterStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // 업로드 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Obx(() {
                    final count = controller.selectedIndices.length;
                    return SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed:
                        controller.isUploading.value ? null : controller.upload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.inactive,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isUploading.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          '업로드 ($count장)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 저장 로딩 오버레이
          Positioned.fill(
            child: Obx(() => controller.isUploading.value
                ? const _UploadingOverlay()
                : const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 저장 로딩 오버레이
// ─────────────────────────────────────────────────────────────

class _UploadingOverlay extends StatelessWidget {
  const _UploadingOverlay();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  color: AppColors.main,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 18),
              Text(
                '추억을 저장하고 있어요',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '잠시만 기다려 주세요',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 4 - 업로드 완료
// ─────────────────────────────────────────────────────────────

class _CompleteStep extends GetView<CameraController> {
  const _CompleteStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      // 완료 아이콘
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.divider,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 40,
                            color: AppColors.main,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 완료 문구
                      const Text(
                        "업로드 완료",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.6,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 18),
                      Obx(() {
                        return RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.7,
                            ),
                            children: [

                              TextSpan(
                                text: "${controller.uploadedCount.value}장의 사진을 ",
                              ),

                              TextSpan(
                                text: controller.completedAlbumTitle.value,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const TextSpan(
                                text: "에 저장했습니다.",
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 44),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.divider,
                          ),
                        ),
                        child: Obx(() {
                          return Column(
                            children: [

                              Row(
                                children: [

                                  const Text(
                                    "사진",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    "${controller.uploadedCount.value}장",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: Divider(height: 1),
                              ),

                              Row(
                                children: [

                                  const Text(
                                    "앨범",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),

                                  const Spacer(),

                                  Flexible(
                                    child: Text(
                                      controller.completedAlbumTitle.value,
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                      const Spacer(),
                      Column(
                        children: [

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: controller.goToAlbum,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.main,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "앨범 보기",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: controller.continueShooting,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                  color: AppColors.divider,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "새 사진 촬영",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}