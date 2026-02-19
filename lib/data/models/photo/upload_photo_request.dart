class UploadPhotoRequest {
  final int albumId;
  final String imageUrl;
  final String? message;

  UploadPhotoRequest({
    required this.albumId,
    required this.imageUrl,
    this.message,
  });

  Map<String, dynamic> toJson() => {
    'albumId': albumId,
    'imageUrl': imageUrl,
    if (message != null && message!.isNotEmpty) 'message': message,
  };
}