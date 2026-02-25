import '../../../domain/entities/moment.dart';
import 'photo_dto.dart';

class MomentDto {
  final String date;                // YYYY-MM-DD
  final List<PhotoDto> photos;
  final List<String> contributors;  // 닉네임 리스트

  MomentDto({
    required this.date,
    required this.photos,
    required this.contributors,
  });

  factory MomentDto.fromJson(Map<String, dynamic> json) {
    return MomentDto(
      date: json['date'] as String,
      photos: (json['photos'] as List<dynamic>)
          .map((p) => PhotoDto.fromJson(p as Map<String, dynamic>))
          .toList(),
      contributors: (json['contributors'] as List<dynamic>)
          .map((c) => c as String)
          .toList(),
    );
  }

  Moment toEntity() {
    return Moment(
      date: date,
      photos: photos.map((p) => p.toEntity()).toList(),
      contributors: contributors,
    );
  }
}