import '../../../domain/entities/album.dart';

class AlbumDto {
  final String id;
  final String title;
  final List<String> categories;
  final String eventStartDate;
  final String? eventEndDate;
  final String? coverImageUrl;
  final String inviteCode;
  final int photoCount;
  final int memberCount;
  final String createdAt;
  final String? updatedAt;
  final String? lastPhotoUploadedAt;

  // 권한
  final String ownerId;  // 목록 응답에 없으면 currentUserId로 대체
  final String role;
  final String? currentUserId;
  final bool isAdmin;

  AlbumDto({
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
    this.lastPhotoUploadedAt,
    required this.ownerId,
    required this.role,
    this.currentUserId,
    this.isAdmin = false,
  });

  factory AlbumDto.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final role = json['role'] as String? ?? 'MEMBER';
    // 서버가 ownerId를 내려주지 않는 경우: OWNER면 currentUserId가 ownerId
    final ownerId = json['ownerId'] as String?
        ?? (role == 'OWNER' ? (currentUserId ?? '') : '');

    return AlbumDto(
      id: json['albumId'] as String,
      title: json['title'] as String,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      eventStartDate: json['eventStartDate'] as String? ?? '',
      eventEndDate: json['eventEndDate'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      inviteCode: json['inviteCode'] as String? ?? '',
      photoCount: json['photoCount'] as int? ?? 0,
      memberCount: json['memberCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
      lastPhotoUploadedAt: json['lastPhotoUploadedAt'] as String?,
      ownerId: ownerId,
      role: role,
      currentUserId: currentUserId,
      isAdmin: role == 'ADMIN',
    );
  }

  Album toEntity() {
    return Album(
      id: id,
      title: title,
      categories: categories,
      eventStartDate: eventStartDate,
      eventEndDate: eventEndDate,
      coverImageUrl: coverImageUrl,
      inviteCode: inviteCode,
      photoCount: photoCount,
      memberCount: memberCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      lastPhotoUploadedAt: lastPhotoUploadedAt != null
          ? DateTime.parse(lastPhotoUploadedAt!)
          : null,
      ownerId: ownerId,
      currentUserId: currentUserId ?? '',
      role: role,
      isAdmin: isAdmin,
    );
  }
}