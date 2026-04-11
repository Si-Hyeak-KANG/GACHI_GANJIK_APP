import '../enum/album_role.dart';

class Album {
  final String id;
  final String title;
  final List<String> categories;
  final String eventStartDate;
  final String? eventEndDate;
  final String? coverImageUrl;
  final String inviteCode;
  final int photoCount;
  final int memberCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String ownerId;
  final String currentUserId;
  final String role;       // 서버 응답: "OWNER" | "ADMIN" | "MEMBER" | "GUEST"
  final bool isAdmin;      // 로컬 전용 (하위 호환용)

  Album({
    required this.id,
    required this.title,
    required this.categories,
    required this.eventStartDate,
    this.eventEndDate,
    this.coverImageUrl,
    required this.inviteCode,
    required this.photoCount,
    required this.memberCount,
    required this.createdAt,
    this.updatedAt,
    required this.ownerId,
    required this.currentUserId,
    required this.role,
    this.isAdmin = false,
  });

  AlbumRole get albumRole {
    switch (role) {
      case 'OWNER':
        return AlbumRole.owner;
      case 'ADMIN':
        return AlbumRole.admin;
      case 'GUEST':
        return AlbumRole.guest;
      default:
        if (isAdmin) return AlbumRole.admin;
        return AlbumRole.member;
    }
  }

  bool get isOwner => role == 'OWNER';
  bool get canManage => albumRole.canManage;  // OWNER + ADMIN
  bool get canShare => canManage;

  String get categoriesDisplay {
    if (categories.isEmpty) return '';
    return categories.join(' · ');
  }

  String get eventDateDisplay {
    if (eventEndDate == null || eventEndDate == eventStartDate) {
      return _formatDate(eventStartDate);
    }
    return '${_formatDate(eventStartDate)} ~ ${_formatDate(eventEndDate!)}';
  }

  String _formatDate(String isoDate) => isoDate.replaceAll('-', '.');

  String get qrCodeData => 'gachiganjik://join?code=$inviteCode';
  String get shareLink => 'https://gachiganjik.app/join?code=$inviteCode';
}