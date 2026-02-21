class Album {
  final int id;
  final String title;
  final List<String> categories;
  final String eventStartDate;
  final String? eventEndDate;
  final String? coverImage;
  final String inviteCode;
  final int photoCount;
  final int memberCount;
  final String createdAt;

  Album({
    required this.id,
    required this.title,
    required this.categories,
    required this.eventStartDate,
    this.eventEndDate,
    this.coverImage,
    required this.inviteCode,
    required this.photoCount,
    required this.memberCount,
    required this.createdAt,
  });

  // 날짜 파싱 헬퍼
  DateTime get createdAtAsDateTime {
    try {
      final dateStr = createdAt.trim();
      if (dateStr.contains('.')) {
        return DateTime.parse(dateStr.replaceAll('.', '-'));
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  // 카테고리 문자열 - 표시용
  String get categoriesDisplay {
    if (categories.isEmpty) return '';
    return categories.join(' · ');
  }

  // 날짜 기간 문자열 - 표시용
  String get eventDateDisplay {
    if (eventEndDate == null || eventEndDate == eventStartDate) {
      return eventStartDate;
    }
    return '$eventStartDate - $eventEndDate';
  }
}