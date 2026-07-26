class Photo {
  final String id;                  // String (UUID)
  final String albumId;             // String (UUID)
  final String? momentId;           // 업로드 배치 식별자 (같은 업로드 = 같은 momentId)
  final String imageUrl;
  final String? thumbnailUrl;
  final String? message;            // 배치 공용 한줄 추억 코멘트
  final String photoDate;

  // 업로더 정보
  final String uploaderId;
  final String uploaderNickname;
  final String? uploaderProfileImageUrl;

  final DateTime createdAt;
  final int likeCount;
  final int commentCount;

  Photo({
    required this.id,
    required this.albumId,
    this.momentId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.message,
    required this.photoDate,
    required this.uploaderId,
    required this.uploaderNickname,
    this.uploaderProfileImageUrl,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  String get photoDateDisplay => photoDate.replaceAll('-', '.');

  String get uploadedAtDisplay {
    final date = createdAt.toLocal();
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get dateOnly => photoDateDisplay;

  String get uploaderInitial => uploaderNickname.isNotEmpty ? uploaderNickname[0] : '?';
}

class Comment {
  final String commentId;
  final String photoId;
  final String userId;
  final String nickname;
  final String? profileImageUrl;
  final String content;
  final DateTime createdAt;
  final bool isMine;

  Comment({
    required this.commentId,
    required this.photoId,
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
    required this.content,
    required this.createdAt,
    this.isMine = false,
  });

  String get createdAtDisplay {
    final date = createdAt.toLocal();
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get initial => nickname.isNotEmpty ? nickname[0] : '?';
}