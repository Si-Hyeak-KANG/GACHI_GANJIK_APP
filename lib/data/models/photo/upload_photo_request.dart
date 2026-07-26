class UploadPhotoRequest {
  final String albumId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? message;
  final String? colorCode;
  final String photoDate;
  final String? momentId;

  UploadPhotoRequest({
    required this.albumId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.message,
    this.colorCode,
    required this.photoDate,
    this.momentId,
  });

  /// POST /albums/{albumId}/photos
  /// Body: { "momentId"?, "photos": [{ imageUrl, thumbnailUrl, message, colorCode }], "photoDate": "..." }
  Map<String, dynamic> toJson() {
    return {
      if (momentId != null) 'momentId': momentId,
      'photos': [
        {
          'imageUrl': imageUrl,
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
          if (message != null) 'message': message,
          if (colorCode != null) 'colorCode': colorCode,
        }
      ],
      'photoDate': photoDate,
    };
  }
}