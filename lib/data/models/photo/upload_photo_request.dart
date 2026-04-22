class UploadPhotoRequest {
  final String albumId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? message;
  final String? colorCode;
  final String photoDate;

  UploadPhotoRequest({
    required this.albumId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.message,
    this.colorCode,
    required this.photoDate,
  });

  /// POST /albums/{albumId}/photos
  /// Body: { "photos": [{ imageUrl, thumbnailUrl, message, colorCode }], "photoDate": "..." }
  Map<String, dynamic> toJson() {
    return {
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