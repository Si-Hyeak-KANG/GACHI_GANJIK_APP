class ApiConstants {
  // 서버 완성 전까지 Mock 사용
  static const String baseUrl = 'https://api.gachiganjik.com';
  static const bool useMock = true;

  // Auth
  static const String login = '/auth/login';
  static const String socialLogin = '/auth/social-login';
  static const String refresh = '/auth/refresh';

  // Album
  static const String albums = '/albums';

  static String albumDetail(int id) => '/albums/$id';
  static String joinAlbum = '/albums/join';

  // Photo
  static String albumPhotos(int albumId) => '/albums/$albumId/photos';

  static String photoDetail(int id) => '/photos/$id';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
