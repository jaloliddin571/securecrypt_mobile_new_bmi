import 'dart:convert';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';

class RSAService {
  /// 🔐 Kalit juftligini yaratish (2048-bit)
  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> generateKeyPair() async {
    final pair = await CryptoUtils.generateRSAKeyPair();

    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      publicKey,
      privateKey,
    );
  }

  /// 🔐 Public key bilan shifrlash (base64)
  static String encrypt(String plainText, RSAPublicKey publicKey) {
    final encryptor = PKCS1Encoding(RSAEngine()) // 👈 PKCS1 qo‘shildi
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final inputBytes = Uint8List.fromList(utf8.encode(plainText));
    final outputBytes = encryptor.process(inputBytes);
    return base64Encode(outputBytes);
  }

  /// 🔓 Private key bilan deshifrlash (base64)
  static String decrypt(String cipherText, RSAPrivateKey privateKey) {
    final decryptor = PKCS1Encoding(RSAEngine()) // 👈 PKCS1 qo‘shildi
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final inputBytes = base64Decode(cipherText);
    final outputBytes = decryptor.process(inputBytes);
    return utf8.decode(outputBytes);
  }

  /// 📥 PEM formatdan public key olish
  static RSAPublicKey parsePublicKeyFromPem(String pem) {
    if (!pem.contains('-----BEGIN PUBLIC KEY-----')) {
      throw ArgumentError('❗ RSA public key noto‘g‘ri formatda. PEM formatda bo‘lishi kerak.');
    }
    return CryptoUtils.rsaPublicKeyFromPem(pem);
  }

  /// 📥 PEM formatdan private key olish
  static RSAPrivateKey parsePrivateKeyFromPem(String pem) {
    if (!pem.contains('-----BEGIN PRIVATE KEY-----')) {
      throw ArgumentError('❗ RSA private key noto‘g‘ri formatda. PEM formatda bo‘lishi kerak.');
    }
    return CryptoUtils.rsaPrivateKeyFromPem(pem);
  }

  /// 📤 Public key ni PEM formatga o‘tkazish
  static String encodePublicKeyToPem(RSAPublicKey publicKey) {
    return CryptoUtils.encodeRSAPublicKeyToPem(publicKey);
  }

  /// 📤 Private key ni PEM formatga o‘tkazish
  static String encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    return CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
  }
}
