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