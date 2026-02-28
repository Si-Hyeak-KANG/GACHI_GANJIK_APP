import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'network_exception.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage, _dio),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  Dio get instance => _dio;

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Options? options,
      }) async {
    try {
      return await _dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Options? options,
      }) async {
    try {
      return await _dio.patch(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
      String path, {
        Options? options,
      }) async {
    try {
      return await _dio.delete(path, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  NetworkException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: '연결 시간이 초과되었습니다',
          type: NetworkExceptionType.connectionTimeout,
        );
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: '응답 시간이 초과되었습니다',
          type: NetworkExceptionType.receiveTimeout,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final body = error.response?.data;

        // 서버 에러코드가 있으면 매핑된 메시지 사용
        if (body is Map<String, dynamic>) {
          final errorCode = body['error']?['code'] as String?;
          if (errorCode != null) {
            return NetworkException.fromErrorCode(errorCode, statusCode);
          }
          final message = body['error']?['message'] as String?;
          if (message != null) {
            return NetworkException(
              message: message,
              statusCode: statusCode,
              type: NetworkExceptionType.serverError,
            );
          }
        }

        return NetworkException(
          message: '서버 오류가 발생했습니다 ($statusCode)',
          statusCode: statusCode,
          type: statusCode == 401
              ? NetworkExceptionType.unauthorized
              : statusCode == 404
              ? NetworkExceptionType.notFound
              : NetworkExceptionType.serverError,
        );
      default:
        return NetworkException(
          message: '네트워크 연결을 확인해주세요',
          type: NetworkExceptionType.noInternet,
        );
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Dio _dio;

  // 토큰 갱신 중 중복 요청 방지
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  _AuthInterceptor(this._secureStorage, this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // GUEST 요청인 경우 X-Guest-Key 헤더 사용
    final guestKey = await _secureStorage.getGuestKey();
    final accessToken = await _secureStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else if (guestKey != null && guestKey.isNotEmpty) {
      options.headers['X-Guest-Key'] = guestKey;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    // 401이고 토큰 갱신 엔드포인트가 아닌 경우만 재시도
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/token/refresh')) {
      if (_isRefreshing) {
        // 갱신 중이면 대기열에 추가
        _pendingRequests.add(_PendingRequest(err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _onRefreshFailed(handler, err);
          return;
        }

        // 토큰 갱신 요청 (인터셉터 우회를 위해 새 Dio 인스턴스 사용)
        final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
        final response = await refreshDio.post(
          '/auth/token/refresh',
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['data']['accessToken'] as String;
        final newRefreshToken = response.data['data']['refreshToken'] as String;

        await _secureStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // 원래 요청 재시도
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);

        // 대기 중인 요청들 재시도
        for (final pending in _pendingRequests) {
          pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
          try {
            final res = await _dio.fetch(pending.options);
            pending.handler.resolve(res);
          } catch (e) {
            pending.handler.next(err);
          }
        }
        _pendingRequests.clear();
      } catch (_) {
        _onRefreshFailed(handler, err);
        // 대기 중인 요청들도 실패 처리
        for (final pending in _pendingRequests) {
          pending.handler.next(err);
        }
        _pendingRequests.clear();
      } finally {
        _isRefreshing = false;
      }
      return;
    }

    handler.next(err);
  }

  void _onRefreshFailed(ErrorInterceptorHandler handler, DioException err) {
    // Refresh 실패 시 토큰 삭제 (로그아웃 처리는 AuthController에서)
    _secureStorage.clearTokens();
    handler.next(err);
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}