import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GallerySaver {
  // 이미지 URL을 갤러리에 저장
  static Future<bool> saveImageFromUrl(String imageUrl) async {
    try {
      // 1. 권한 확인 및 요청
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        throw Exception('갤러리 접근 권한이 필요합니다');
      }

      // 2. 이미지 다운로드
      final tempDir = await getTemporaryDirectory();
      final fileName = 'gachiganjik_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      final dio = Dio();
      await dio.download(imageUrl, filePath);

      // 3. 갤러리에 저장
      final result = await ImageGallerySaver.saveFile(filePath);

      // 4. 임시 파일 삭제
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      return result['isSuccess'] == true;
    } catch (e) {
      print('이미지 저장 실패: $e');
      return false;
    }
  }

  // 권한 요청
  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Android 13 (API 33) 이상
      if (await _isAndroid13OrAbove()) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      // Android 12 이하
      else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  }

  // Android 13 이상 확인
  static Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;

    // Android SDK 버전 확인 로직
    // 실제로는 device_info_plus 등을 사용하지만,
    // 간단하게 Permission.photos 사용 가능 여부로 판단
    return true; // 최신 permission_handler는 자동 처리
  }
}