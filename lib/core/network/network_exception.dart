class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final NetworkExceptionType type;
  final String? errorCode; // 서버 에러코드 (예: "INVALID_CREDENTIALS")

  NetworkException({
    required this.message,
    this.statusCode,
    required this.type,
    this.errorCode,
  });

  @override
  String toString() => message;

  /// 서버 에러코드 → NetworkException 변환
  factory NetworkException.fromErrorCode(
      String errorCode,
      int statusCode,
      ) {
    final message = _errorMessages[errorCode] ?? '알 수 없는 오류가 발생했습니다';
    final type = _errorTypes[statusCode] ?? NetworkExceptionType.unknown;
    return NetworkException(
      message: message,
      statusCode: statusCode,
      type: type,
      errorCode: errorCode,
    );
  }

  /// API 에러코드 → 사용자 메시지 매핑 (API 명세서 10번 기준)
  static const Map<String, String> _errorMessages = {
    // 인증
    'INVALID_CREDENTIALS': '이메일 또는 비밀번호가 올바르지 않습니다',
    'TOKEN_EXPIRED': '로그인이 만료되었습니다. 다시 로그인해주세요',
    'INVALID_REFRESH_TOKEN': '인증 정보가 유효하지 않습니다. 다시 로그인해주세요',
    // 권한
    'PERMISSION_DENIED': '권한이 없습니다',
    'NOT_ALBUM_MEMBER': '앨범 멤버가 아닙니다',
    'NOT_PHOTO_OWNER': '사진 업로더가 아닙니다',
    'NOT_COMMENT_OWNER': '본인의 댓글만 삭제할 수 있습니다',
    'ONLY_OWNER_CAN_PROMOTE': '앨범 소유자만 관리자를 지정할 수 있습니다',
    'CANNOT_CHANGE_OWNER_ROLE': '앨범 소유자의 역할은 변경할 수 없습니다',
    'CANNOT_PROMOTE_GUEST': 'GUEST는 관리자로 승격할 수 없습니다',
    // 리소스 없음
    'ALBUM_NOT_FOUND': '앨범을 찾을 수 없습니다',
    'PHOTO_NOT_FOUND': '사진을 찾을 수 없습니다',
    'COMMENT_NOT_FOUND': '댓글을 찾을 수 없습니다',
    'GUEST_NOT_FOUND': 'GUEST 정보를 찾을 수 없습니다',
    'INVALID_INVITE_CODE': '유효하지 않은 초대 코드입니다',
    // 중복/충돌
    'EMAIL_ALREADY_EXISTS': '이미 사용 중인 이메일입니다',
    'ALREADY_JOINED': '이미 참여 중인 앨범입니다',
    'DUPLICATE_GUEST_KEY': '이미 사용 중인 GUEST KEY입니다',
    'GUEST_ALREADY_CONVERTED': '이미 회원으로 전환된 GUEST KEY입니다',
    // 파일
    'INVALID_FILE_TYPE': '지원하지 않는 파일 형식입니다 (JPEG, PNG, HEIC, WebP)',
    'FILE_SIZE_EXCEEDED': '파일 크기가 초과되었습니다 (최대 10MB)',
    'TOO_MANY_FILES': '한 번에 최대 10장까지 업로드할 수 있습니다',
    // 앨범 제한
    'ALBUM_LIMIT_EXCEEDED': '앨범은 최대 8개까지 생성할 수 있습니다',
    'INVALID_DATE_RANGE': '종료일이 시작일보다 이전일 수 없습니다',
    // 유효성
    'WEAK_PASSWORD': '비밀번호 정책을 충족하지 않습니다',
  };

  static const Map<int, NetworkExceptionType> _errorTypes = {
    400: NetworkExceptionType.badRequest,
    401: NetworkExceptionType.unauthorized,
    403: NetworkExceptionType.forbidden,
    404: NetworkExceptionType.notFound,
    409: NetworkExceptionType.conflict,
    410: NetworkExceptionType.gone,
    422: NetworkExceptionType.badRequest,
    500: NetworkExceptionType.serverError,
  };
}

enum NetworkExceptionType {
  connectionTimeout,
  receiveTimeout,
  unauthorized,
  forbidden,
  serverError,
  noInternet,
  badRequest,
  notFound,
  conflict,
  gone,
  unknown,
}