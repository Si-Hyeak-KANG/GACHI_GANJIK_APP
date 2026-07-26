import '../../../domain/entities/photo.dart';

class PhotoDto {
  final String id;
  final String albumId;
  final String? momentId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? message;
  final String photoDate;
  final String? colorCode;

  final String uploaderId;
  final String uploaderNickname;
  final String? uploaderProfileImageUrl;

  final String createdAt;
  final int likeCount;
  final int commentCount;

  PhotoDto({
    required this.id,
    required this.albumId,
    this.momentId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.message,
    required this.photoDate,
    this.colorCode,
    required this.uploaderId,
    required this.uploaderNickname,
    this.uploaderProfileImageUrl,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  factory PhotoDto.fromJson(Map<String, dynamic> json) {
    // 업로더 정보가 중첩 객체(uploader)로 올 수도 있어 함께 확인
    final uploader = json['uploader'] is Map
        ? (json['uploader'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    // 서버가 uploaderProfileImageUrl / profileImageUrl 중 무엇을 쓰든 대응
    final profileImage = (json['uploaderProfileImageUrl'] ??
        json['profileImageUrl'] ??
        uploader['profileImageUrl'] ??
        uploader['uploaderProfileImageUrl']) as String?;

    return PhotoDto(
      id: json['photoId']?.toString() ?? '',
      albumId: json['albumId']?.toString() ?? '',
      momentId: json['momentId']?.toString(),
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      message: json['message'] as String?,
      photoDate: json['photoDate'] as String,
      colorCode: json['colorCode'] as String?,
      uploaderId: (json['uploaderId'] ?? uploader['userId'] ?? uploader['id'])
          ?.toString() ??
          '',
      uploaderNickname:
      (json['uploaderNickname'] ?? uploader['nickname']) as String? ?? '',
      uploaderProfileImageUrl: profileImage,
      createdAt: json['uploadDt'] as String? ?? json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
    );
  }

  Photo toEntity() {
    return Photo(
      id: id,
      albumId: albumId,
      momentId: momentId,
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
  final bool isMine;

  CommentDto({
    required this.commentId,
    required this.photoId,
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
    required this.content,
    required this.createdAt,
    this.isMine = false,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      commentId: json['commentId']?.toString() ?? '',
      photoId: json['photoId']?.toString() ?? '',
      userId: json['authorId']?.toString() ?? '',
      nickname: json['nickname'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      isMine: json['isMine'] as bool? ?? false,
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
      isMine: isMine,
    );
  }
}