import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class LocalStorage {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User ID
  Future<void> saveUserId(int id) async {
    await _prefs.setInt(StorageKeys.userId, id);
  }

  int? getUserId() {
    return _prefs.getInt(StorageKeys.userId);
  }

  // First Launch
  bool isFirstLaunch() {
    return _prefs.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(StorageKeys.isFirstLaunch, false);
  }

  // Last Sync Time
  Future<void> saveLastSyncTime(DateTime time) async {
    await _prefs.setString(StorageKeys.lastSyncTime, time.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final str = _prefs.getString(StorageKeys.lastSyncTime);
    return str != null ? DateTime.parse(str) : null;
  }

  // Clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}