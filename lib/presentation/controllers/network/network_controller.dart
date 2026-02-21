import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../../../core/services/sync_service.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  final RxBool isConnected = true.obs;
  final RxBool wasOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _listenToConnectionChanges();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _listenToConnectionChanges() {
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;

    // 오프라인 → 온라인 전환 감지
    if (!isConnected.value && connected) {
      wasOffline.value = true;

      // SyncService를 통해 동기화
      Future.delayed(const Duration(seconds: 1), () {
        _triggerSync();
        wasOffline.value = false;
      });
    }

    isConnected.value = connected;
  }

  // SyncService 호출
  void _triggerSync() {
    try {
      final syncService = Get.find<SyncService>();
      syncService.syncAll();
    } catch (e) {
      print('동기화 서비스를 찾을 수 없습니다: $e');
    }
  }
}