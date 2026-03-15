import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../routes/app_pages.dart';
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
      _JwtInterceptor(_secureStorage, _dio),
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

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  NetworkException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: '연결 시간 초과. 네트워크를 확인해주세요.',
          type: NetworkExceptionType.connectionTimeout,
        );
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: '응답 시간 초과. 잠시 후 다시 시도해주세요.',
          type: NetworkExceptionType.receiveTimeout,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      default:
        return NetworkException(
          message: '네트워크 연결을 확인해주세요.',
          type: NetworkExceptionType.noInternet,
        );
    }
  }

  NetworkException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // 서버 에러코드 추출 { "success": false, "error": { "code": "...", "message": "..." } }
    final errorCode = data?['error']?['code'] as String?;
    final errorMessage = data?['error']?['message'] as String?;

    switch (errorCode) {
      case 'EMAIL_ALREADY_EXISTS':
        return NetworkException(
          message: '이미 사용 중인 이메일입니다.',
          type: NetworkExceptionType.badRequest,
          statusCode: statusCode,
        );
      case 'INVALID_CREDENTIALS':
        return NetworkException(
          message: '이메일 또는 비밀번호가 올바르지 않습니다.',
          type: NetworkExceptionType.unauthorized,
          statusCode: statusCode,
        );
      case 'WEAK_PASSWORD':
        return NetworkException(
          message: '비밀번호는 영문+숫자+특수문자 조합 8~20자여야 합니다.',
          type: NetworkExceptionType.badRequest,
          statusCode: statusCode,
        );
      case 'INVALID_REFRESH_TOKEN':
      case 'TOKEN_EXPIRED':
        return NetworkException(
          message: '로그인이 만료되었습니다. 다시 로그인해주세요.',
          type: NetworkExceptionType.unauthorized,
          statusCode: statusCode,
        );
      default:
        if (statusCode == 401) {
          return NetworkException(
            message: '인증이 필요합니다.',
            type: NetworkExceptionType.unauthorized,
            statusCode: statusCode,
          );
        } else if (statusCode == 403) {
          return NetworkException(
            message: '접근 권한이 없습니다.',
            type: NetworkExceptionType.forbidden,
            statusCode: statusCode,
          );
        } else if (statusCode == 404) {
          return NetworkException(
            message: '요청한 리소스를 찾을 수 없습니다.',
            type: NetworkExceptionType.notFound,
            statusCode: statusCode,
          );
        }
        return NetworkException(
          message: errorMessage ?? '서버 오류가 발생했습니다.',
          type: NetworkExceptionType.serverError,
          statusCode: statusCode,
        );
    }
  }
}

class _JwtInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Dio _dio;

  // 토큰 갱신 중 중복 요청 방지
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  _JwtInterceptor(this._secureStorage, this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    // 401이 아니거나 토큰 갱신 요청 자체가 실패한 경우 → 그냥 통과
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path == ApiConstants.tokenRefresh) {
      handler.next(err);
      return;
    }

    // 서버 에러코드 확인
    final errorCode = err.response?.data?['error']?['code'] as String?;
    final isTokenError = errorCode == 'TOKEN_EXPIRED' ||
        errorCode == 'INVALID_REFRESH_TOKEN' ||
        err.response?.statusCode == 401;

    if (!isTokenError) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // 이미 갱신 중이면 대기열에 추가
      final pendingRequest = _PendingRequest(err.requestOptions, handler);
      _pendingRequests.add(pendingRequest);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _forceLogout();
        handler.reject(err);
        return;
      }

      // 토큰 갱신 요청 (인터셉터 우회를 위해 새 Dio 인스턴스 사용)
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await refreshDio.post(
        ApiConstants.tokenRefresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['data']['accessToken'] as String;
      final newRefreshToken = response.data['data']['refreshToken'] as String;

      await _secureStorage.saveAccessToken(newAccessToken);
      await _secureStorage.saveRefreshToken(newRefreshToken);

      // 원래 요청 재시도
      final retryResponse = await _retry(err.requestOptions, newAccessToken);
      handler.resolve(retryResponse);

      // 대기 중인 요청들도 재시도
      for (final pending in _pendingRequests) {
        try {
          final r = await _retry(pending.options, newAccessToken);
          pending.handler.resolve(r);
        } catch (e) {
          pending.handler.reject(err);
        }
      }
    } catch (e) {
      // 갱신 실패 → 강제 로그아웃
      await _forceLogout();
      handler.reject(err);
      for (final pending in _pendingRequests) {
        pending.handler.reject(err);
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<Response> _retry(RequestOptions options, String accessToken) async {
    return await _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {
          ...options.headers,
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

  Future<void> _forceLogout() async {
    await _secureStorage.clearTokens();
    Get.offAllNamed(Routes.login);
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}