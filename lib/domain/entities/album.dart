import '../enum/album_role.dart';

class Album {
  final int id;
  final String title;
  final List<String> categories;
  final String eventStartDate;
  final String? eventEndDate;
  final String? coverImage;
  final String inviteCode;
  final int photoCount;
  final int memberCount;
  final String createdAt;

  final int ownerId; // 앨범 생성자 ID
  final int currentUserId; // 현재 로그인한 사용자 ID
  final bool isAdmin;

  Album({
    required this.id,
    required this.title,
    required this.categories,
    required this.eventStartDate,
    this.eventEndDate,
    this.coverImage,
    required this.inviteCode,
    required this.photoCount,
    required this.memberCount,
    required this.createdAt,
    required this.ownerId,
    required this.currentUserId,
    this.isAdmin = false,
  });

  AlbumRole get role {
    if (currentUserId == ownerId) return AlbumRole.owner;
    if (isAdmin) return AlbumRole.admin;
    if (currentUserId > 0) return AlbumRole.member;
    return AlbumRole.guest;
  }

  bool get isOwner => currentUserId == ownerId;
  bool get canManage => isOwner || isAdmin;
  bool get canShare => canManage;

  // 날짜 파싱 헬퍼
  DateTime get createdAtAsDateTime {
    try {
      final dateStr = createdAt.trim();
      if (dateStr.contains('.')) {
        return DateTime.parse(dateStr.replaceAll('.', '-'));
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  // 카테고리 문자열 - 표시용
  String get categoriesDisplay {
    if (categories.isEmpty) return '';
    return categories.join(' · ');
  }

  // 날짜 기간 문자열 - 표시용
  String get eventDateDisplay {
    if (eventEndDate == null || eventEndDate == eventStartDate) {
      return eventStartDate;
    }
    return '$eventStartDate - $eventEndDate';
  }

  String get qrCodeData => 'gachiganjik://join?code=$inviteCode';
  String get shareLink => 'https://gachiganjik.app/join?code=$inviteCode';
}