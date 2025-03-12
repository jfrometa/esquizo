import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  SharedPreferences? _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // String operations
  Future<bool> setString(String key, String value) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(key, value);
  }
  
  Future<String?> getString(String key) async {
    if (_prefs == null) await init();
    return _prefs!.getString(key);
  }
  
  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) await init();
    return await _prefs!.setBool(key, value);
  }
  
  Future<bool?> getBool(String key) async {
    if (_prefs == null) await init();
    return _prefs!.getBool(key);
  }
  
  // Integer operations
  Future<bool> setInt(String key, int value) async {
    if (_prefs == null) await init();
    return await _prefs!.setInt(key, value);
  }
  
  Future<int?> getInt(String key) async {
    if (_prefs == null) await init();
    return _prefs!.getInt(key);
  }
  
  // Double operations
  Future<bool> setDouble(String key, double value) async {
    if (_prefs == null) await init();
    return await _prefs!.setDouble(key, value);
  }
  
  Future<double?> getDouble(String key) async {
    if (_prefs == null) await init();
    return _prefs!.getDouble(key);
  }
  
  // String list operations
  Future<bool> setStringList(String key, List<String> value) async {
    if (_prefs == null) await init();
    return await _prefs!.setStringList(key, value);
  }
  
  Future<List<String>?> getStringList(String key) async {
    if (_prefs == null) await init();
    return _prefs!.getStringList(key);
  }
  
  // Remove and clear operations
  Future<bool> remove(String key) async {
    if (_prefs == null) await init();
    return await _prefs!.remove(key);
  }
  
  Future<bool> clear() async {
    if (_prefs == null) await init();
    return await _prefs!.clear();
  }
}

// Provider for local storage service
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});