import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UpdateService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'auto_update';

  static Future<void> setAutoUpdate(bool value) async {
    await _storage.write(key: _key, value: value.toString());
  }

  static Future<bool> getAutoUpdate() async {
    final result = await _storage.read(key: _key);
    return result == 'true'; // default false
  }
}
