import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:convert';

class SteganographyService {
  /// 📥 Matnni rasmga yashirish (LSB)
  static Uint8List hideTextInImage(Uint8List imageBytes, String text) {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Rasmni o'qib bo'lmadi");

    final encodedText = utf8.encode("##MSG##$text\0");
    final bits = <int>[];

    for (var byte in encodedText) {
      for (int i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1);
      }
    }

    int bitIndex = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        if (bitIndex < bits.length) r = (r & ~1) | bits[bitIndex++];
        if (bitIndex < bits.length) g = (g & ~1) | bits[bitIndex++];
        if (bitIndex < bits.length) b = (b & ~1) | bits[bitIndex++];

        image.setPixelRgba(x, y, r, g, b);
        if (bitIndex >= bits.length) break;
      }
      if (bitIndex >= bits.length) break;
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  /// 📤 Rasm ichidan matnni ajratib olish
  static String extractTextFromImage(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Rasmni o'qib bo'lmadi");

    final bits = <int>[];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        bits.add(img.getRed(pixel) & 1);
        bits.add(img.getGreen(pixel) & 1);
        bits.add(img.getBlue(pixel) & 1);
      }
    }

    final bytes = <int>[];
    for (int i = 0; i + 7 < bits.length; i += 8) {
      int byte = 0;
      for (int j = 0; j < 8; j++) {
        byte = (byte << 1) | bits[i + j];
      }
      bytes.add(byte);
      if (bytes.length >= 7 &&
          utf8.decode(bytes, allowMalformed: true).endsWith("\0")) {
        break;
      }
    }

    final message = utf8.decode(bytes, allowMalformed: true);
    if (message.startsWith("##MSG##")) {
      return message.replaceAll("##MSG##", "").replaceAll("\0", "");
    } else {
      return "Yashirilgan matn topilmadi!";
    }
  }
}
