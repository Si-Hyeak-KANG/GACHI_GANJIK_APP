class UpdateAlbumRequest {
  final String? title;
  final List<String>? categories;
  final String? eventStartDate;
  final String? eventEndDate;
  final String? coverImageUrl;

  UpdateAlbumRequest({
    this.title,
    this.categories,
    this.eventStartDate,
    this.eventEndDate,
    this.coverImageUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (categories != null) map['categories'] = categories;
    if (eventStartDate != null) map['eventStartDate'] = eventStartDate;
    if (eventEndDate != null) map['eventEndDate'] = eventEndDate;
    if (coverImageUrl != null) map['coverImageUrl'] = coverImageUrl;
    return map;
  }
}