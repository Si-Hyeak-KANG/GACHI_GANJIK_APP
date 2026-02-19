import 'dart:io';
import '../entities/photo.dart';
import '../entities/moment.dart';

abstract class PhotoRepository {
  Future<List<Moment>> getAlbumMoments(int albumId);
  Future<Photo> uploadPhoto({
    required int albumId,
    required File imageFile,
    String? message,
  });
}