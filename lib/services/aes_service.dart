import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class AESCipher {
  /// Matnni AES yordamida CBC rejimda shifrlaydi.
  /// [plainText] - shifrlanadigan matn.
  /// [key] - foydalanuvchi kiritgan kalit.
  static String encrypt(String plainText, String key) {
    if (key.isEmpty) {
      throw ArgumentError('Kalit bo\'sh bo\'lishi mumkin emas.');
    }

    final keyBytes = sha256.convert(utf8.encode(key)).bytes;
    final aesKey = Key(Uint8List.fromList(keyBytes));
    final iv = IV.fromSecureRandom(16); // Har safar yangi IV

    final encrypter = Encrypter(AES(aesKey, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final resultBytes = iv.bytes + encrypted.bytes;
    return base64Encode(resultBytes);
  }

  /// AES yordamida CBC rejimda deshifrlash.
  /// [base64Encrypted] - base64 shaklidagi shifrlangan matn.
  /// [key] - kalit.
  static String decrypt(String base64Encrypted, String key) {
    if (key.isEmpty) {
      throw ArgumentError('Kalit bo\'sh bo\'lishi mumkin emas.');
    }

    final encryptedBytes = base64Decode(base64Encrypted);
    final iv = IV(encryptedBytes.sublist(0, 16));
    final cipherText = encryptedBytes.sublist(16);

    final keyBytes = sha256.convert(utf8.encode(key)).bytes;
    final aesKey = Key(Uint8List.fromList(keyBytes));

    final encrypter = Encrypter(AES(aesKey, mode: AESMode.cbc, padding: 'PKCS7'));
    final decrypted = encrypter.decrypt(Encrypted(Uint8List.fromList(cipherText)), iv: iv);

    return decrypted;
  }
}
