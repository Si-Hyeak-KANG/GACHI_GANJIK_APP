import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageSource {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ✅ 추가: 프로필 이미지 업로드
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // 1. 이미지 압축
      final compressedFile = await _compressImage(imageFile);

      // 2. Storage 경로 생성
      // profiles/{timestamp}_{filename}
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = path.basename(imageFile.path);
      final storagePath = 'profiles/${timestamp}_$fileName';

      // 3. 업로드
      final ref = _storage.ref().child(storagePath);
      await ref.putFile(compressedFile);

      // 4. 다운로드 URL 반환
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('프로필 이미지 업로드 실패: $e');
    }
  }
  
  // 이미지 업로드
  // 왜 압축? → 1MB 이하로 줄여서 업로드 속도 향상 & Storage 비용 절감
  Future<String> uploadImage(File imageFile, String albumId) async {
    try {
      // 1. 이미지 압축
      final compressedFile = await _compressImage(imageFile);

      // 2. Storage 경로 생성
      // albums/{albumId}/photos/{timestamp}_{filename}
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = path.basename(imageFile.path);
      final storagePath = 'albums/$albumId/photos/${timestamp}_$fileName';

      // 3. 업로드
      final ref = _storage.ref().child(storagePath);
      await ref.putFile(compressedFile);

      // 4. 다운로드 URL 반환
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  // 이미지 압축 (1MB 이하)
  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf('.');
    final outPath = '${filePath.substring(0, lastIndex)}_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw Exception('이미지 압축 실패');
    }

    return File(result.path);
  }

  // 이미지 삭제 (Phase 4 이후 사용)
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // 이미 삭제되었거나 없는 경우 무시
    }
  }
}