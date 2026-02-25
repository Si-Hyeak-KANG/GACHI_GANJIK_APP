import '../enum/album_role.dart';

class Album {
  final String id;                  // ✅ String (UUID)
  final String title;
  final List<String> categories;
  final String eventStartDate;      // ✅ YYYY-MM-DD 형식
  final String? eventEndDate;
  final String? coverImageUrl;      // ✅ coverImage → coverImageUrl
  final String inviteCode;
  final int photoCount;
  final int memberCount;
  final DateTime createdAt;         // ✅ DateTime
  final DateTime? updatedAt;        // ✅ 추가

  // 권한 관련
  final String ownerId;             // ✅ String (UUID)
  final String currentUserId;       // ✅ String (UUID)
  final String role;                // ✅ "OWNER" | "MEMBER"
  final bool isAdmin;               // ✅ 로컬 전용 (API 없음)

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
    if (role == 'OWNER') return AlbumRole.owner;
    if (isAdmin) return AlbumRole.admin;  // 로컬 전용
    if (currentUserId.isNotEmpty) return AlbumRole.member;
    return AlbumRole.guest;
  }

  bool get isOwner => role == 'OWNER';
  bool get canManage => isOwner || isAdmin;
  bool get canShare => canManage;

  // 카테고리 문자열
  String get categoriesDisplay {
    if (categories.isEmpty) return '';
    return categories.join(' · ');
  }

  // 날짜 기간 문자열
  String get eventDateDisplay {
    if (eventEndDate == null || eventEndDate == eventStartDate) {
      return _formatDate(eventStartDate);
    }
    return '${_formatDate(eventStartDate)} ~ ${_formatDate(eventEndDate!)}';
  }

  // YYYY-MM-DD → YYYY.MM.DD 변환 (UI 표시용)
  String _formatDate(String isoDate) {
    return isoDate.replaceAll('-', '.');
  }

  String get qrCodeData => 'gachiganjik://join?code=$inviteCode';
  String get shareLink => 'https://gachiganjik.app/join?code=$inviteCode';
}