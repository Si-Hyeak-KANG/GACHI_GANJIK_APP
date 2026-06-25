import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/repositories/guest_repository.dart';
import '../../../data/sources/remote/album_remote_source.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/storage/secure_storage.dart';

enum GuestEntryStep { albumEntry, nickname }

class GuestEntryController extends GetxController {
  final GuestRepository _guestRepository;
  final SecureStorage _secureStorage;
  final AlbumRemoteSource _albumRemoteSource;

  GuestEntryController({
    required GuestRepository guestRepository,
    required SecureStorage secureStorage,
    required AlbumRemoteSource albumRemoteSource,
  })  : _guestRepository = guestRepository,
        _secureStorage = secureStorage,
        _albumRemoteSource = albumRemoteSource;

  // ─────────────────────────────────────────
  // Step 상태
  // ─────────────────────────────────────────
  final Rx<GuestEntryStep> currentStep = GuestEntryStep.albumEntry.obs;

  // ─────────────────────────────────────────
  // STEP 1 - 앨범 입장
  // ─────────────────────────────────────────
  final inviteCodeController = TextEditingController();
  final RxBool isQrMode = false.obs;
  final RxString qrError = ''.obs;

  // ─────────────────────────────────────────
  // STEP 2 - 닉네임 입력
  // ─────────────────────────────────────────
  final nicknameController = TextEditingController();
  final RxString nicknameError = ''.obs;

  // ─────────────────────────────────────────
  // 공통
  // ─────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString inviteCodeText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    inviteCodeController.addListener(() {
      inviteCodeText.value = inviteCodeController.text;
    });
  }

  @override
  void onClose() {
    inviteCodeController.dispose();
    nicknameController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────
  // STEP 1 액션
  // ─────────────────────────────────────────

  void toggleQrMode() {
    isQrMode.value = !isQrMode.value;
    qrError.value = '';
  }

  /// QR 스캔 결과 처리
  void onQrDetected(String raw) {
    // QR에서 inviteCode 추출 (예: "gachiganjik://invite?code=ABCD1234")
    final uri = Uri.tryParse(raw);
    String? code;
    if (uri != null && uri.queryParameters.containsKey('code')) {
      code = uri.queryParameters['code'];
    } else if (raw.length >= 6) {
      // 단순 코드 문자열인 경우
      code = raw.trim();
    }

    if (code == null || code.isEmpty) {
      qrError.value = '올바르지 않은 QR 코드입니다';
      return;
    }

    inviteCodeController.text = code;
    isQrMode.value = false;
    _proceedToNickname();
  }

  String? _validateInviteCode(String value) {
    if (value.trim().isEmpty) return '앨범 코드를 입력해주세요';
    return null;
  }

  Future<void> confirmInviteCode() async {
    final error = _validateInviteCode(inviteCodeController.text);
    if (error != null) {
      errorMessage.value = error;
      return;
    }
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _albumRemoteSource.verifyInviteCode(inviteCodeController.text.trim());
      _proceedToNickname();
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = '앨범을 찾을 수 없습니다.';
    } finally {
      isLoading.value = false;
    }
  }

  void _proceedToNickname() {
    currentStep.value = GuestEntryStep.nickname;
  }

  // ─────────────────────────────────────────
  // STEP 2 액션
  // ─────────────────────────────────────────

  String? validateNickname(String value) {
    if (value.trim().isEmpty) return '이름을 입력해주세요';
    if (value.trim().length < 2) return '2자 이상 입력해주세요';
    if (value.trim().length > 20) return '20자 이하로 입력해주세요';
    return null;
  }

  Future<void> confirmNicknameAndJoin() async {
    final error = validateNickname(nicknameController.text);
    if (error != null) {
      nicknameError.value = error;
      return;
    }
    nicknameError.value = '';
    await _registerGuest();
  }

  Future<void> _registerGuest() async {
    isLoading.value = true;
    try {
      // deviceId: SecureStorage에 저장된 값 재사용, 없으면 신규 생성
      String? deviceId = await _secureStorage.getDeviceId();
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = const Uuid().v4();
        await _secureStorage.saveDeviceId(deviceId);
      }

      final response = await _guestRepository.register(
        guestKey: deviceId,
        nickname: nicknameController.text.trim(),
        inviteCode: inviteCodeController.text.trim(),
      );

      // albumId를 arguments로 전달하여 앨범 상세로 이동
      Get.offAllNamed(
        Routes.albumDetail,
        arguments: {'albumId': response.albumId},
      );
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      // 에러 발생 시 step 1로 복귀
      currentStep.value = GuestEntryStep.albumEntry;
    } catch (_) {
      errorMessage.value = '입장에 실패했습니다. 코드를 확인해주세요.';
      currentStep.value = GuestEntryStep.albumEntry;
    } finally {
      isLoading.value = false;
    }
  }
}