import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class GallerySaver {
  // 이미지 URL을 갤러리에 저장
  static Future<bool> saveImageFromUrl(String imageUrl) async {
    try {
      // 1. 권한 확인 및 요청
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          throw Exception('갤러리 접근 권한이 필요합니다');
        }
      }

      // 2. 로컬 파일이면 바로 저장
      if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
        final path = imageUrl.replaceFirst('file://', '');
        await Gal.putImage(path);
        return true;
      }

      // 3. 네트워크 이미지면 다운로드 후 저장
      final tempDir = await getTemporaryDirectory();
      final fileName = 'gachiganjik_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      await Dio().download(imageUrl, filePath);
      await Gal.putImage(filePath);

      // 4. 임시 파일 삭제
      final file = File(filePath);
      if (await file.exists()) await file.delete();

      return true;
    } catch (e) {
      print('이미지 저장 실패: $e');
      return false;
    }
  }
}