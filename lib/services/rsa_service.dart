import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';
import 'package:path_provider/path_provider.dart';

class RSAService {
  // Kalit juftligini yaratish (bitLength parametrli)
  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> generateKeyPair({int bitLength = 2048}) async {
    final secureRandom = _getSecureRandom();
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          secureRandom,
        ),
      );

    final pair = keyGen.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );
  }

  // Xavfsiz random generator
  static SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final seed = Uint8List.fromList(List.generate(32, (_) => Random.secure().nextInt(256)));
    secureRandom.seed(KeyParameter(seed));
    return secureRandom;
  }

  // RSA matn shifrlash
  static String encrypt(String plainText, RSAPublicKey publicKey) {
    final encryptor = PKCS1Encoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final input = Uint8List.fromList(utf8.encode(plainText));
    final output = encryptor.process(input);
    return base64Encode(output);
  }

  // RSA shifrdan yechish
  static String decrypt(String cipherText, RSAPrivateKey privateKey) {
    final decryptor = PKCS1Encoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final input = base64Decode(cipherText);
    final output = decryptor.process(input);
    return utf8.decode(output);
  }

  // Kalitlarni PEM formatga o‘tkazish
  static String encodePublicKey(RSAPublicKey key) => CryptoUtils.encodeRSAPublicKeyToPem(key);
  static String encodePrivateKey(RSAPrivateKey key) => CryptoUtils.encodeRSAPrivateKeyToPem(key);

  // PEM dan kalitlarni o‘qish
  static RSAPublicKey decodePublicKey(String pem) => CryptoUtils.rsaPublicKeyFromPem(pem);
  static RSAPrivateKey decodePrivateKey(String pem) => CryptoUtils.rsaPrivateKeyFromPem(pem);

  // 🔒 PEM faylga saqlash
  static Future<void> saveKeysToPem({
    required String publicKeyPem,
    required String privateKeyPem,
    required String fileNamePrefix,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final publicKeyFile = File('${dir.path}/${fileNamePrefix}_public.pem');
    final privateKeyFile = File('${dir.path}/${fileNamePrefix}_private.pem');

    await publicKeyFile.writeAsString(publicKeyPem);
    await privateKeyFile.writeAsString(privateKeyPem);
  }
}
