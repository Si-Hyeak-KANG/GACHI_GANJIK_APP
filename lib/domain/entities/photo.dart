class Photo {
  final int id;
  final int albumId;
  final String imageUrl;
  final String? message;
  final String uploader;
  final String uploadedAt;
  final int likeCount;
  final List<Comment> comments;

  Photo({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    this.message,
    required this.uploader,
    required this.uploadedAt,
    this.likeCount = 0,
    this.comments = const [],
  });

  // 날짜만 추출 (YYYY.MM.DD)
  String get dateOnly {
    if (uploadedAt.length >= 10) {
      return uploadedAt.substring(0, 10);
    }
    return uploadedAt;
  }
}

class Comment {
  final String user;
  final String text;

  Comment({required this.user, required this.text});
}