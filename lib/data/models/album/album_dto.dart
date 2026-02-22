import '../../../domain/entities/album.dart';

class AlbumDto {
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
  final int ownerId;
  final int currentUserId;
  final bool isAdmin;

  AlbumDto({
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

  factory AlbumDto.fromJson(Map<String, dynamic> json) {
    return AlbumDto(
      id: json['id'] as int,
      title: json['title'] as String,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      eventStartDate: json['eventStartDate'] as String,
      eventEndDate: json['eventEndDate'] as String?,
      coverImage: json['coverImage'] as String?,
      inviteCode: json['inviteCode'] as String,
      photoCount: json['photoCount'] as int,
      memberCount: json['memberCount'] as int,
      createdAt: json['createdAt'] as String,
      ownerId: json['ownerId'] as int,
      currentUserId: json['currentUserId'] as int,
      isAdmin: json['isAdmin'] as bool ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categories': categories,
      'eventStartDate': eventStartDate,
      'eventEndDate': eventEndDate,
      'coverImage': coverImage,
      'inviteCode': inviteCode,
      'photoCount': photoCount,
      'memberCount': memberCount,
      'createdAt': createdAt,
      'ownerId' : ownerId,
      'currentUserId' : currentUserId,
      'isAdmin' : isAdmin
    };
  }

  Album toEntity() {
    return Album(
      id: id,
      title: title,
      categories: categories,
      eventStartDate: eventStartDate,
      eventEndDate: eventEndDate,
      coverImage: coverImage,
      inviteCode: inviteCode,
      photoCount: photoCount,
      memberCount: memberCount,
      createdAt: createdAt,
      ownerId: ownerId,
      currentUserId: currentUserId,
      isAdmin: isAdmin,
    );
  }
}