class UploadPhotoRequest {
  final String albumId;
  final String imageUrl;
  final String? message;
  final String photoDate;

  UploadPhotoRequest({
    required this.albumId,
    required this.imageUrl,
    this.message,
    required this.photoDate,
  });

  // ✅ 실제 API용 (multipart/form-data)
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'photoDate': photoDate,
    };
  }
}