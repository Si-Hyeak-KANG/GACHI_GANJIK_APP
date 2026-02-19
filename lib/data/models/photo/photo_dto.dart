import '../../../domain/entities/photo.dart';

class PhotoDto {
  final int id;
  final int albumId;
  final String imageUrl;
  final String? message;
  final String uploader;
  final String uploadedAt;
  final int likeCount;
  final List<CommentDto> comments;

  PhotoDto({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    this.message,
    required this.uploader,
    required this.uploadedAt,
    this.likeCount = 0,
    this.comments = const [],
  });

  factory PhotoDto.fromJson(Map<String, dynamic> json) {
    return PhotoDto(
      id: json['id'] as int,
      albumId: json['albumId'] as int,
      imageUrl: json['imageUrl'] as String,
      message: json['message'] as String?,
      uploader: json['uploader'] as String,
      uploadedAt: json['uploadedAt'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      comments: (json['comments'] as List?)
          ?.map((c) => CommentDto.fromJson(c as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Photo toEntity() {
    return Photo(
      id: id,
      albumId: albumId,
      imageUrl: imageUrl,
      message: message,
      uploader: uploader,
      uploadedAt: uploadedAt,
      likeCount: likeCount,
      comments: comments.map((c) => c.toEntity()).toList(),
    );
  }
}

class CommentDto {
  final String user;
  final String text;

  CommentDto({required this.user, required this.text});

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      user: json['user'] as String,
      text: json['text'] as String,
    );
  }

  Comment toEntity() => Comment(user: user, text: text);
}