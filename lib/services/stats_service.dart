import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static Future<void> increment(String key) async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, count + 1);
  }

  static Future<int> getCount(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }
  static Future<int> getQrDecryptCount() async {
    return await getCount('qr_decrypt_count');
  }

  static Future<void> resetAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('caesar_count');
    await prefs.remove('vigenere_count');
    await prefs.remove('aes_count');
    await prefs.remove('rsa_count');
    await prefs.remove('file_enc_count');
    await prefs.remove('stegano_count');
    await prefs.remove('qr_decrypt_count');
  }
}
