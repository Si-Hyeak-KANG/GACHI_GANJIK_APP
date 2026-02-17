import '../../../domain/entities/album.dart';

class AlbumDto {
  final int id;
  final String title;
  final String? category;
  final String? eventDate;
  final String? coverImage;
  final String inviteCode;
  final int photoCount;
  final int memberCount;
  final String createdAt;

  AlbumDto({
    required this.id,
    required this.title,
    this.category,
    this.eventDate,
    this.coverImage,
    required this.inviteCode,
    required this.photoCount,
    required this.memberCount,
    required this.createdAt,
  });

  factory AlbumDto.fromJson(Map<String, dynamic> json) {
    return AlbumDto(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String?,
      eventDate: json['eventDate'] as String?,
      coverImage: json['coverImage'] as String?,
      inviteCode: json['inviteCode'] as String,
      photoCount: json['photoCount'] as int,
      memberCount: json['memberCount'] as int,
      createdAt: json['createdAt'] as String,
    );
  }

  Album toEntity() {
    return Album(
      id: id,
      title: title,
      category: category,
      eventDate: eventDate,
      coverImage: coverImage,
      inviteCode: inviteCode,
      photoCount: photoCount,
      memberCount: memberCount,
      createdAt: createdAt,
    );
  }
}