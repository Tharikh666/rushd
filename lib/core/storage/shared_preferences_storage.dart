import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage.dart';

class SharedPreferencesStorage implements LocalStorage {
  SharedPreferencesStorage(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<void> writeString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<String?> readString(String key) async {
    return _preferences.getString(key);
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  @override
  Future<bool?> readBool(String key) async {
    return _preferences.getBool(key);
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  @override
  Future<void> clear() async {
    await _preferences.clear();
  }
}
