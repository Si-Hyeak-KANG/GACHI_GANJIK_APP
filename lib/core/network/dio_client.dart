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
        _showNoConnectionSnackbar();
        return NetworkException(
          message: '연결 시간 초과. 네트워크를 확인해주세요.',
          type: NetworkExceptionType.connectionTimeout,
        );
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: '응답 시간 초과. 잠시 후 다시 시도해주세요.',
          type: NetworkExceptionType.receiveTimeout,
        );
      case DioExceptionType.connectionError:
        _showNoConnectionSnackbar();
        return NetworkException(
          message: '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.',
          type: NetworkExceptionType.noInternet,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      default:
        _showNoConnectionSnackbar();
        return NetworkException(
          message: '네트워크 연결을 확인해주세요.',
          type: NetworkExceptionType.noInternet,
        );
    }
  }

  NetworkException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;

    String? errorCode;
    String? errorMessage;
    try {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final errorObj = data['error'];
        if (errorObj is Map<String, dynamic>) {
          errorCode = errorObj['code'] as String?;
          errorMessage = errorObj['message'] as String?;
        }
      }
    } catch (_) {}

    switch (errorCode) {
      case 'EMAIL_ALREADY_EXISTS':
        return NetworkException(
          message: '이미 사용 중인 이메일입니다.',
          type: NetworkExceptionType.badRequest,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'INVALID_CREDENTIALS':
        return NetworkException(
          message: '이메일 또는 비밀번호가 올바르지 않습니다.',
          type: NetworkExceptionType.unauthorized,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'WEAK_PASSWORD':
        return NetworkException(
          message: '비밀번호는 영문+숫자+특수문자 조합 8~20자여야 합니다.',
          type: NetworkExceptionType.badRequest,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'TOKEN_EXPIRED':
      case 'INVALID_REFRESH_TOKEN':
        return NetworkException(
          message: '로그인이 만료되었습니다. 다시 로그인해주세요.',
          type: NetworkExceptionType.unauthorized,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'ALBUM_LIMIT_EXCEEDED':
        return NetworkException(
          message: '앨범은 최대 8개까지 생성할 수 있습니다.',
          type: NetworkExceptionType.forbidden,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'EMAIL_VERIFICATION_NOT_FOUND':
        return NetworkException(
          message: '인증 코드가 만료되었습니다. 다시 요청해주세요.',
          type: NetworkExceptionType.notFound,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'EMAIL_VERIFICATION_INVALID':
        return NetworkException(
          message: '인증 코드가 올바르지 않습니다.',
          type: NetworkExceptionType.badRequest,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'INVALID_INVITE_CODE':
        return NetworkException(
          message: '유효하지 않은 초대 코드입니다.',
          type: NetworkExceptionType.notFound,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'ALREADY_JOINED':
        return NetworkException(
          message: '이미 참여 중인 앨범입니다.',
          type: NetworkExceptionType.conflict,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'PERMISSION_DENIED':
        return NetworkException(
          message: '권한이 없습니다.',
          type: NetworkExceptionType.forbidden,
          statusCode: statusCode,
          errorCode: errorCode,
        );
    // ── Phase 12: Photos ──────────────────────────────
      case 'NOT_PHOTO_OWNER':
        return NetworkException(
          message: '본인이 업로드한 사진만 수정할 수 있습니다.',
          type: NetworkExceptionType.forbidden,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'PHOTO_NOT_FOUND':
        return NetworkException(
          message: '사진을 찾을 수 없습니다.',
          type: NetworkExceptionType.notFound,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'TOO_MANY_FILES':
        return NetworkException(
          message: '한 번에 최대 10장까지 업로드할 수 있습니다.',
          type: NetworkExceptionType.badRequest,
          statusCode: statusCode,
          errorCode: errorCode,
        );

    // ── Phase 13: Comments ────────────────────────────
      case 'NOT_COMMENT_OWNER':
        return NetworkException(
          message: '본인의 댓글만 삭제할 수 있습니다.',
          type: NetworkExceptionType.forbidden,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'COMMENT_NOT_FOUND':
        return NetworkException(
          message: '댓글을 찾을 수 없습니다.',
          type: NetworkExceptionType.notFound,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'NOT_ALBUM_MEMBER':
        return NetworkException(
          message: '앨범 멤버만 이용할 수 있습니다.',
          type: NetworkExceptionType.forbidden,
          statusCode: statusCode,
          errorCode: errorCode,
        );

    // ── Phase 15: Guest ───────────────────────────────
      case 'GUEST_KEY_ALREADY_EXISTS':
        return NetworkException(
          message: '이미 사용 중인 GUEST ID입니다.',
          type: NetworkExceptionType.conflict,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'GUEST_NOT_FOUND':
        return NetworkException(
          message: 'GUEST 정보를 찾을 수 없습니다.',
          type: NetworkExceptionType.notFound,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      case 'GUEST_ALREADY_CONVERTED':
        return NetworkException(
          message: '이미 회원 전환된 GUEST ID입니다.',
          type: NetworkExceptionType.gone,
          statusCode: statusCode,
          errorCode: errorCode,
        );
// ─────────────────────────────────────────────────
      default:
        if (statusCode == 401) {
          return NetworkException(
            message: '인증이 필요합니다. 다시 로그인해주세요.',
            type: NetworkExceptionType.unauthorized,
            statusCode: statusCode,
          );
        } else if (statusCode == 403) {
          return NetworkException(
            message: errorMessage ?? '접근 권한이 없습니다.',
            type: NetworkExceptionType.forbidden,
            statusCode: statusCode,
          );
        } else if (statusCode == 404) {
          return NetworkException(
            message: errorMessage ?? '요청한 리소스를 찾을 수 없습니다.',
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

  void _showNoConnectionSnackbar() {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      '네트워크 오류',
      '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}

class _JwtInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Dio _dio;

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
    } else {
      final guestKey = await _secureStorage.getGuestKey();
      if (guestKey != null && guestKey.isNotEmpty) {
        options.headers['X-Guest-Key'] = guestKey;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    final statusCode = err.response?.statusCode;

    if (err.requestOptions.path == ApiConstants.tokenRefresh) {
      handler.next(err);
      return;
    }

    String? errorCode;
    try {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        final errorObj = data['error'];
        if (errorObj is Map<String, dynamic>) {
          errorCode = errorObj['code'] as String?;
        }
      }
    } catch (_) {}

    final isCredentialError = errorCode == 'INVALID_CREDENTIALS' ||
        errorCode == 'EMAIL_ALREADY_EXISTS';

    final guestKey = await _secureStorage.getGuestKey();
    final isGuestSession = guestKey != null && guestKey.isNotEmpty;

    final isTokenError = !isCredentialError &&
        !isGuestSession &&
        (errorCode == 'TOKEN_EXPIRED' ||
            errorCode == 'INVALID_REFRESH_TOKEN' ||
            statusCode == 401);

    if (!isTokenError) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add(_PendingRequest(err.requestOptions, handler));
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

      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await refreshDio.post(
        ApiConstants.tokenRefresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['data']['accessToken'] as String;
      final newRefreshToken = response.data['data']['refreshToken'] as String;

      await _secureStorage.saveAccessToken(newAccessToken);
      await _secureStorage.saveRefreshToken(newRefreshToken);

      final retryResponse = await _retry(err.requestOptions, newAccessToken);
      handler.resolve(retryResponse);

      for (final pending in _pendingRequests) {
        try {
          final r = await _retry(pending.options, newAccessToken);
          pending.handler.resolve(r);
        } catch (e) {
          pending.handler.reject(err);
        }
      }
    } catch (e) {
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
    Get.snackbar(
      '로그인 만료',
      '다시 로그인해주세요.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.offAllNamed(Routes.login);
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}