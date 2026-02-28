// API 명세서 5.6 앨범 수정 요청
class UpdateAlbumRequest {
  final String? title;
  final List<String>? categories;
  final String? eventStartDate; // YYYY-MM-DD
  final String? eventEndDate;   // YYYY-MM-DD

  UpdateAlbumRequest({
    this.title,
    this.categories,
    this.eventStartDate,
    this.eventEndDate,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (categories != null) json['categories'] = categories;
    if (eventStartDate != null) json['eventStartDate'] = eventStartDate;
    if (eventEndDate != null) json['eventEndDate'] = eventEndDate;
    return json;
  }
}