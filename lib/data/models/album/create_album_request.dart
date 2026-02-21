class CreateAlbumRequest {
  final String title;
  final List<String> categories;
  final String eventStartDate;
  final String? eventEndDate;

  CreateAlbumRequest({
    required this.title,
    required this.categories,
    required this.eventStartDate,
    this.eventEndDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'categories': categories,
      'eventStartDate': eventStartDate,
      'eventEndDate': eventEndDate,
    };
  }
}