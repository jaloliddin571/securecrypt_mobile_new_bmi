class VigenereCipher {
  /// Matnni Vigenère shifri yordamida shifrlaydi
  static String encrypt(String text, String key) {
    if (key.isEmpty) return text;

    final buffer = StringBuffer();
    key = key.toLowerCase(); // kalit kichik harflarda ishlatiladi
    int keyIndex = 0;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);

      if (_isUpperCase(code)) {
        final base = 'A'.codeUnitAt(0);
        final shift = key.codeUnitAt(keyIndex % key.length) - 'a'.codeUnitAt(0);
        final encryptedChar = ((code - base + shift) % 26 + base);
        buffer.write(String.fromCharCode(encryptedChar));
        keyIndex++;
      } else if (_isLowerCase(code)) {
        final base = 'a'.codeUnitAt(0);
        final shift = key.codeUnitAt(keyIndex % key.length) - 'a'.codeUnitAt(0);
        final encryptedChar = ((code - base + shift) % 26 + base);
        buffer.write(String.fromCharCode(encryptedChar));
        keyIndex++;
      } else {
        buffer.write(char); // belgilar o'zgarishsiz qoladi
      }
    }

    return buffer.toString();
  }

  /// Vigenère shifridagi matnni asl holatga qaytaradi (deshifrlaydi)
  static String decrypt(String text, String key) {
    if (key.isEmpty) return text;

    final buffer = StringBuffer();
    key = key.toLowerCase();
    int keyIndex = 0;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);

      if (_isUpperCase(code)) {
        final base = 'A'.codeUnitAt(0);
        final shift = key.codeUnitAt(keyIndex % key.length) - 'a'.codeUnitAt(0);
        final decryptedChar = ((code - base - shift + 26) % 26 + base);
        buffer.write(String.fromCharCode(decryptedChar));
        keyIndex++;
      } else if (_isLowerCase(code)) {
        final base = 'a'.codeUnitAt(0);
        final shift = key.codeUnitAt(keyIndex % key.length) - 'a'.codeUnitAt(0);
        final decryptedChar = ((code - base - shift + 26) % 26 + base);
        buffer.write(String.fromCharCode(decryptedChar));
        keyIndex++;
      } else {
        buffer.write(char); // belgilar o'zgarishsiz qoladi
      }
    }

    return buffer.toString();
  }

  static bool _isUpperCase(int code) => code >= 65 && code <= 90;
  static bool _isLowerCase(int code) => code >= 97 && code <= 122;
}
