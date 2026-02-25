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
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _listenToConnectionChanges() {
    _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected = results.any((r) => r != ConnectivityResult.none);

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