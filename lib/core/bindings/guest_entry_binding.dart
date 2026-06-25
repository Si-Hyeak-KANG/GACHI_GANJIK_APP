import 'package:get/get.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../domain/repositories/guest_repository.dart';
import '../../data/sources/remote/album_remote_source.dart';
import '../../presentation/controllers/auth/guest_entry_controller.dart';

class GuestEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuestEntryController>(
          () => GuestEntryController(
        guestRepository: Get.find<GuestRepository>(),
        secureStorage: Get.find<SecureStorage>(),
        albumRemoteSource: Get.find<AlbumRemoteSource>(),
      ),
    );
  }
}