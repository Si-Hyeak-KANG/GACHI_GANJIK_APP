import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageSource {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── 압축 설정 ──────────────────────────────────────
  // 프로필: 원형 소형 표시 → 해상도 낮게, 용량 최소화
  static const _profileMaxSize = 400;
  static const _profileQuality = 80;

  // 앨범 커버: 카드 썸네일 표시 → 중간 해상도
  static const _coverMaxSize = 800;
  static const _coverQuality = 82;

  // 일반 사진: 전체화면 상세 보기 → 고해상도 유지
  static const _photoMaxWidth = 1920;
  static const _photoMaxHeight = 1080;
  static const _photoQuality = 85;
  // ──────────────────────────────────────────────────

  /// 프로필 이미지 업로드
  /// 경로: profiles/{timestamp}_{filename}
  /// 압축: 400x400, quality 80 → 약 30~60KB
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final compressedFile = await _compressImage(
        imageFile,
        maxWidth: _profileMaxSize,
        maxHeight: _profileMaxSize,
        quality: _profileQuality,
      );

      final storagePath = _buildPath(
        'profiles',
        path.basename(imageFile.path),
      );

      return await _uploadAndGetUrl(compressedFile, storagePath);
    } catch (e) {
      throw Exception('프로필 이미지 업로드 실패: $e');
    }
  }

  /// 앨범 커버 이미지 업로드
  /// 경로: albums/{albumId}/covers/{timestamp}_{filename}
  /// 압축: 800x800, quality 82 → 약 80~150KB
  Future<String> uploadCoverImage(File imageFile, String albumId) async {
    try {
      final compressedFile = await _compressImage(
        imageFile,
        maxWidth: _coverMaxSize,
        maxHeight: _coverMaxSize,
        quality: _coverQuality,
      );

      final storagePath = _buildPath(
        'albums/$albumId/covers',
        path.basename(imageFile.path),
      );

      return await _uploadAndGetUrl(compressedFile, storagePath);
    } catch (e) {
      throw Exception('커버 이미지 업로드 실패: $e');
    }
  }

  /// 일반 사진 업로드
  /// 경로: albums/{albumId}/photos/{timestamp}_{filename}
  /// 압축: 1920x1080, quality 85 → 약 200~500KB
  Future<String> uploadImage(File imageFile, String albumId) async {
    try {
      final compressedFile = await _compressImage(
        imageFile,
        maxWidth: _photoMaxWidth,
        maxHeight: _photoMaxHeight,
        quality: _photoQuality,
      );

      final storagePath = _buildPath(
        'albums/$albumId/photos',
        path.basename(imageFile.path),
      );

      return await _uploadAndGetUrl(compressedFile, storagePath);
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // 이미 삭제되었거나 없는 경우 무시
    }
  }

  // ── Private ──────────────────────────────────────

  /// 타임스탬프 기반 Storage 경로 생성
  String _buildPath(String folder, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$folder/${timestamp}_$fileName';
  }

  /// 업로드 후 다운로드 URL 반환
  Future<String> _uploadAndGetUrl(File file, String storagePath) async {
    final ref = _storage.ref().child(storagePath);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// 이미지 압축
  /// keepExif: false → 위치정보 등 메타데이터 제거 (용량 추가 절감)
  Future<File> _compressImage(
      File file, {
        required int maxWidth,
        required int maxHeight,
        required int quality,
      }) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf('.');
    final outPath = '${filePath.substring(0, lastIndex)}_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (result == null) {
      throw Exception('이미지 압축 실패');
    }

    return File(result.path);
  }
}