import 'dart:async';

class SecureStoreManager {
  final _storage = const FlutterSecureStorage();

  IOSOptions _getIOSOptions() => const IOSOptions(
        accountName: 'ios',
      );
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  static final SecureStoreManager instance = SecureStoreManager();

  Future<Map<String, String>> readAll() async {
    return _storage.readAll(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
  }

  Future<void> deleteAll() async {
    return _storage.deleteAll(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
  }

  Future<void> write(String key, value) async {
    return _storage.write(
      key: key,
      value: value,
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
  }

  Future<String> read(String key) async {
    return await _storage.read(
          key: key,
          aOptions: _getAndroidOptions(),
          iOptions: _getIOSOptions(),
        ) ??
        'key_not_found';
  }
}
