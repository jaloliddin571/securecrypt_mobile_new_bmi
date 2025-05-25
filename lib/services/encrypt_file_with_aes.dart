import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

Future<void> encryptFileWithAES(String password) async {
  try {
    final XFile? selectedFile = await openFile(); // file_selector

    if (selectedFile == null) {
      print('❗ Fayl tanlanmadi');
      return;
    }

    final inputBytes = await selectedFile.readAsBytes();
    final fileName = selectedFile.name;

    // AES kalit va IV
    final key = encrypt.Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final aes = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = aes.encryptBytes(inputBytes, iv: iv);

    final dir = await getDownloadsDirectory(); // Androidda /storage/emulated/0/Download
    final encryptedFile = File('${dir!.path}/encrypted_$fileName');

    await encryptedFile.writeAsBytes(encrypted.bytes);

    print('✅ Shifrlangan fayl saqlandi: ${encryptedFile.path}');
  } catch (e) {
    print('⚠️ Xatolik: $e');
  }
}
