class CaesarCipher {
  /// Matnni Caesar shifri bilan shifrlash
  static String encrypt(String text, int shift) {
    return _process(text, shift);
  }

  /// Matnni Caesar shifri bilan deshifrlash
  static String decrypt(String text, int shift) {
    return _process(text, -shift);
  }

  /// Ichki ishlovchi funksiya: shifrlash va deshifrlashni umumlashtiradi
  static String _process(String text, int shift) {
    return text.split('').map((char) {
      final code = char.codeUnitAt(0);

      if (_isUpperCase(code)) {
        final base = 'A'.codeUnitAt(0);
        return String.fromCharCode(((code - base + shift) % 26 + 26) % 26 + base);
      } else if (_isLowerCase(code)) {
        final base = 'a'.codeUnitAt(0);
        return String.fromCharCode(((code - base + shift) % 26 + 26) % 26 + base);
      } else {
        return char; // boshqa belgilar o‘zgarmaydi
      }
    }).join('');
  }

  static bool _isUpperCase(int code) => code >= 65 && code <= 90;
  static bool _isLowerCase(int code) => code >= 97 && code <= 122;
}
