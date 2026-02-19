import 'photo.dart';

// 날짜별로 그룹핑된 사진 모음
class Moment {
  final String date;
  final List<Photo> photos;
  final List<String> contributors;

  Moment({
    required this.date,
    required this.photos,
    required this.contributors,
  });
}