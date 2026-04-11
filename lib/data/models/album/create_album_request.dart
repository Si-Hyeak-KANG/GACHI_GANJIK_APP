class CreateAlbumRequest {
  final String title;
  final List<String> categories;
  final String eventStartDate;
  final String? eventEndDate;
  final String? coverImageUrl;

  CreateAlbumRequest({
    required this.title,
    required this.categories,
    required this.eventStartDate,
    this.eventEndDate,
    this.coverImageUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'categories': categories,
      'eventStartDate': eventStartDate,
    };
    if (eventEndDate != null) map['eventEndDate'] = eventEndDate;
    if (coverImageUrl != null) map['coverImageUrl'] = coverImageUrl;
    return map;
  }
}