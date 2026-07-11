class AlbumEvent {
  final String type;
  final String albumId;
  final String uploadedBy;
  final int photoCount;
  final DateTime lastPhotoUploadedAt;

  AlbumEvent({
    required this.type,
    required this.albumId,
    required this.uploadedBy,
    required this.photoCount,
    required this.lastPhotoUploadedAt,
  });

  factory AlbumEvent.fromJson(Map<String, dynamic> json) {
    return AlbumEvent(
      type: json['type'] as String,
      albumId: json['albumId']?.toString() ?? '',
      uploadedBy: json['uploadedBy'] as String? ?? '',
      photoCount: json['photoCount'] as int? ?? 0,
      lastPhotoUploadedAt: DateTime.parse(
        json['lastPhotoUploadedAt'] as String,
      ),
    );
  }
}