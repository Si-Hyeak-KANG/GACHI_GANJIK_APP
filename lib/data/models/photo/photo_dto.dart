import '../../../domain/entities/photo.dart';

class PhotoDto {
  final String id;                  // String (UUID)
  final String albumId;             // String (UUID)
  final String imageUrl;
  final String? thumbnailUrl;
  final String? message;
  final String photoDate;

  final String uploaderId;          // String (UUID)
  final String uploaderNickname;
  final String? uploaderProfileImageUrl;

  final String createdAt;
  final int likeCount;
  final int commentCount;

  PhotoDto({
    required this.id,
    required this.albumId,
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

  // ✅ API 응답 파싱
  factory PhotoDto.fromJson(Map<String, dynamic> json) {
    return PhotoDto(
      id: json['photoId'] as String,
      albumId: json['albumId'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      message: json['message'] as String?,
      photoDate: json['photoDate'] as String,
      uploaderId: json['uploaderId'] as String,
      uploaderNickname: json['uploaderNickname'] as String,
      uploaderProfileImageUrl: json['uploaderProfileImageUrl'] as String?,
      createdAt: json['createdAt'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
    );
  }

  Photo toEntity() {
    return Photo(
      id: id,
      albumId: albumId,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      message: message,
      photoDate: photoDate,
      uploaderId: uploaderId,
      uploaderNickname: uploaderNickname,
      uploaderProfileImageUrl: uploaderProfileImageUrl,
      createdAt: DateTime.parse(createdAt),
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }
}

class CommentDto {
  final String commentId;
  final String photoId;
  final String userId;
  final String nickname;
  final String? profileImageUrl;
  final String content;
  final String createdAt;

  CommentDto({
    required this.commentId,
    required this.photoId,
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      commentId: json['commentId'] as String,
      photoId: json['photoId'] as String,
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  Comment toEntity() {
    return Comment(
      commentId: commentId,
      photoId: photoId,
      userId: userId,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      content: content,
      createdAt: DateTime.parse(createdAt),
    );
  }
}