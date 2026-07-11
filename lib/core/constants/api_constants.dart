class ApiConstants {
  // ─────────────────────────────────────────
  // 🔧 서버 URL 설정
  // ─────────────────────────────────────────
  // Android 에뮬레이터: http://10.0.2.2:8080
  // iOS 시뮬레이터:     http://localhost:8080
  // 실제 기기(Mac IP):  http://192.168.x.x:8080
  // 운영 서버:          https://api.gachiganjik.com
  static const String _host = 'http://localhost:8080';
  // static const String _host = 'http://192.168.45.208:8080';
  static const String baseUrl = '$_host/api/v1';

  // ─────────────────────────────────────────
  // Auth 엔드포인트
  // ─────────────────────────────────────────
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String tokenRefresh = '/auth/token/refresh';
  static const String googleLogin = '/auth/social/google';
  static const String withdraw = '/auth/withdraw';

  // ─────────────────────────────────────────
  // User 엔드포인트
  // ─────────────────────────────────────────
  static const String me = '/users/me';
  static const String profileImage = '/users/me/profile-image';

  // ─────────────────────────────────────────
  // Album 엔드포인트
  // ─────────────────────────────────────────
  static const String albums = '/albums';
  static const String joinAlbum = '/albums/join';
  static String albumDetail(String id) => '/albums/$id';
  static String albumMembers(String id) => '/albums/$id/members';

  // ─────────────────────────────────────────
  // Photo 엔드포인트
  // ─────────────────────────────────────────
  static String albumPhotos(String albumId) => '/albums/$albumId/photos';
  static String photoDetail(String albumId, String photoId) =>
      '/albums/$albumId/photos/$photoId';

  // ─────────────────────────────────────────
  // Comment 엔드포인트
  // ─────────────────────────────────────────
  static String photoComments(String albumId, String photoId) =>
      '/albums/$albumId/photos/$photoId/comments';
  static String commentDetail(String albumId, String photoId, String commentId) =>
      '/albums/$albumId/photos/$photoId/comments/$commentId';

  // ─────────────────────────────────────────
  // Reaction 엔드포인트
  // ─────────────────────────────────────────
  static String photoLike(String albumId, String photoId) =>
      '/albums/$albumId/photos/$photoId/like';

  // ─────────────────────────────────────────
  // Timeout
  // ─────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}