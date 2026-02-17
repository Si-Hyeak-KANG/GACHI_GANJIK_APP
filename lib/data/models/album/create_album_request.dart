class CreateAlbumRequest {
  final String title;
  final String? category;
  final String? eventDate;

  CreateAlbumRequest({
    required this.title,
    this.category,
    this.eventDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    if (category != null) 'category': category,
    if (eventDate != null) 'eventDate': eventDate,
  };
}