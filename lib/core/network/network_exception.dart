class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final NetworkExceptionType type;

  NetworkException({
    required this.message,
    this.statusCode,
    required this.type,
  });

  @override
  String toString() => message;
}

enum NetworkExceptionType {
  connectionTimeout,
  receiveTimeout,
  unauthorized,
  serverError,
  noInternet,
  badRequest,
  notFound,
  unknown,
}
