import 'photo.dart';

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
}