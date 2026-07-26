import 'photo.dart';

/// 업로드 배치 단위 추억
/// - 한 번의 업로드(같은 momentId)로 올린 사진들 + 한줄 코멘트 + 업로더 1명
class Moment {
  final String date;
  final List<Photo> photos;
  final List<String> contributors;

  Moment({
    required this.date,
    required this.photos,
    required this.contributors,
  });

  String get dateDisplay => date.replaceAll('-', '.');

  String? get momentId => photos.isNotEmpty ? photos.first.momentId : null;

  // ── 업로더 (배치 내 모든 사진이 동일 업로더) ──
  String get uploaderNickname =>
      photos.isNotEmpty ? photos.first.uploaderNickname : '';

  String? get uploaderProfileImageUrl =>
      photos.isNotEmpty ? photos.first.uploaderProfileImageUrl : null;

  String get uploaderInitial =>
      uploaderNickname.isNotEmpty ? uploaderNickname[0] : '·';

  // ── 한줄 추억 코멘트 (배치 공용, 없으면 null) ──
  String? get comment {
    if (photos.isEmpty) return null;
    final text = photos.first.message;
    return (text != null && text.trim().isNotEmpty) ? text : null;
  }

  // ── 업로드 날짜 ──
  DateTime? get uploadedAt => photos.isNotEmpty ? photos.first.createdAt : null;

  String get uploadedDateDisplay {
    final d = uploadedAt?.toLocal();
    if (d == null) return dateDisplay;
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }
}