import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../../data/models/album/album_event.dart';

class WebSocketService extends GetxService {
  final SecureStorage _secureStorage;

  WebSocketService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  StompClient? _client;

  final RxBool isConnected = false.obs;

  // albumId → 구독 취소 함수
  final Map<String, StompUnsubscribe> _subscriptions = {};

  // 이벤트 리스너 — albumId → callback
  final Map<String, void Function(AlbumEvent)> _listeners = {};

  // ─────────────────────────────────────────
  // 연결
  // ─────────────────────────────────────────

  Future<void> connect() async {
    if (_client?.connected == true) return;

    final headers = <String, String>{};

    final guestKey = await _secureStorage.getGuestKey();
    if (guestKey != null && guestKey.isNotEmpty) {
      headers['X-Guest-Key'] = guestKey;
    } else {
      final token = await _getValidAccessToken();
      if (token == null) return; // 인증 불가 — 연결 시도하지 않음
      headers['Authorization'] = 'Bearer $token';
    }

    final wsUrl = ApiConstants.baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://')
        .replaceFirst('/api/v1', '/ws');

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        onConnect: _onConnected,
        onDisconnect: (_) => isConnected.value = false,
        onWebSocketError: (error) {
          isConnected.value = false;
          _scheduleReconnect();
        },
        onStompError: (frame) {
          isConnected.value = false;
          // 인증 오류는 재연결해도 의미 없으므로 스킵
          final message = frame.body ?? '';
          if (message.contains('auth') || message.contains('rejected')) return;
          _scheduleReconnect();
        },
        reconnectDelay: Duration.zero, // 자동 재연결 비활성화 — 수동으로만 재연결
      ),
    );

    _client!.activate();
  }

  void _onConnected(StompFrame frame) {
    isConnected.value = true;
    // 기존 리스너들 재구독 (재연결 시)
    for (final albumId in List.of(_listeners.keys)) {
      _subscribeToAlbum(albumId);
    }
  }

  // ─────────────────────────────────────────
  // 토큰 갱신
  // ─────────────────────────────────────────

  /// 저장된 accessToken 반환. 만료 시 refreshToken으로 갱신 후 반환.
  /// 갱신도 실패하면 null 반환.
  Future<String?> _getValidAccessToken() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return token;

      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.post(
        ApiConstants.tokenRefresh,
        data: {'refreshToken': refreshToken},
      );
      final newAccessToken = response.data['data']['accessToken'] as String;
      final newRefreshToken = response.data['data']['refreshToken'] as String;
      await _secureStorage.saveAccessToken(newAccessToken);
      await _secureStorage.saveRefreshToken(newRefreshToken);
      return newAccessToken;
    } catch (_) {
      // refresh 실패 시 기존 토큰으로 시도
      return token;
    }
  }

  // ─────────────────────────────────────────
  // 구독
  // ─────────────────────────────────────────

  void subscribeToAlbum(String albumId, void Function(AlbumEvent) onEvent) {
    _listeners[albumId] = onEvent;
    if (_client?.connected == true) {
      _subscribeToAlbum(albumId);
    }
  }

  void _subscribeToAlbum(String albumId) {
    if (_subscriptions.containsKey(albumId)) return;

    final unsubscribe = _client!.subscribe(
      destination: '/topic/albums/$albumId',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          final event = AlbumEvent.fromJson(json);
          _listeners[albumId]?.call(event);
        } catch (_) {}
      },
    );
    _subscriptions[albumId] = unsubscribe;
  }

  void unsubscribeFromAlbum(String albumId) {
    _subscriptions[albumId]?.call();
    _subscriptions.remove(albumId);
    _listeners.remove(albumId);
  }

  void unsubscribeAll() {
    for (final unsub in _subscriptions.values) {
      unsub();
    }
    _subscriptions.clear();
    _listeners.clear();
  }

  // ─────────────────────────────────────────
  // 재연결
  // ─────────────────────────────────────────

  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!isConnected.value) connect();
    });
  }

  // ─────────────────────────────────────────
  // 해제
  // ─────────────────────────────────────────

  void disconnect() {
    unsubscribeAll();
    _client?.deactivate();
    _client = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}