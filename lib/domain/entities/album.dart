class Album {
  final int id;
  final String title;
  final String? category;
  final String? eventDate;
  final String? coverImage;
  final String inviteCode;
  final int photoCount;
  final int memberCount;
  final String createdAt;

  Album({
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
}