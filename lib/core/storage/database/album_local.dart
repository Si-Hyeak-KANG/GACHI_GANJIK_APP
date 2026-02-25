import 'package:isar_community/isar.dart';

part 'album_local.g.dart';

@collection
class AlbumLocal {
  Id id = Isar.autoIncrement;

  @Index()
  late String albumId;

  late String title;
  String? categoriesJson;
  String? eventStartDate;
  String? eventEndDate;
  String? coverImageUrl;
  late String inviteCode;
  int photoCount = 0;
  int memberCount = 0;
  late DateTime createdAt;
  DateTime? updatedAt;
  late DateTime lastSyncedAt;

  @Index()
  String syncStatus = 'synced';     // synced, pending, failed

  late String ownerId;
  late String currentUserId;
  late String role;
  bool isAdmin = false;
}