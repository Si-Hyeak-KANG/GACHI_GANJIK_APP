import 'dart:io';
import '../../domain/entities/moment.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../models/photo/upload_photo_request.dart';
import '../sources/firebase/firebase_storage_source.dart';
import '../sources/local/photo_local_source.dart';
import '../sources/remote/photo_remote_source.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteSource _remoteSource;
  final PhotoLocalSource _localSource;
  final FirebaseStorageSource _storageSource;

  PhotoRepositoryImpl({
    required PhotoRemoteSource remoteSource,
    required PhotoLocalSource localSource,
    required FirebaseStorageSource storageSource,
  })  : _remoteSource = remoteSource,
        _localSource = localSource,
        _storageSource = storageSource;

  @override
  Future<List<Moment>> getAlbumMoments(int albumId) async {
    // 1. 원격에서 조회
    final dtos = await _remoteSource.getAlbumPhotos(albumId);

    // 2. 로컬에 저장 (오프라인 대비)
    for (final dto in dtos) {
      await _localSource.savePhoto(dto);
    }

    // 3. Entity 변환
    final photos = dtos.map((dto) => dto.toEntity()).toList();

    // 4. 날짜별 그룹핑
    return _groupByDate(photos);
  }

  @override
  Future<Photo> uploadPhoto({
    required int albumId,
    required File imageFile,
    String? message,
  }) async {
    // 1. Firebase Storage에 이미지 업로드
    final imageUrl = await _storageSource.uploadImage(imageFile, albumId);

    // 2. Mock API에 사진 정보 저장
    final dto = await _remoteSource.uploadPhoto(
      UploadPhotoRequest(
        albumId: albumId,
        imageUrl: imageUrl,
        message: message,
      ),
    );

    // 3. 로컬에 저장
    await _localSource.savePhoto(dto);

    return dto.toEntity();
  }

  // 날짜별 그룹핑 헬퍼
  List<Moment> _groupByDate(List<Photo> photos) {
    final Map<String, List<Photo>> grouped = {};

    for (final photo in photos) {
      final date = photo.dateOnly;
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(photo);
    }

    return grouped.entries.map((entry) {
      final contributors = entry.value.map((p) => p.uploader).toSet().toList();
      return Moment(
        date: entry.key,
        photos: entry.value,
        contributors: contributors,
      );
    }).toList();
  }
}