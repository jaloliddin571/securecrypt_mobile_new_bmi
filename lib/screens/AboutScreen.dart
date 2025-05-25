import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00FFAB)),
        title: const Text('ℹ️ Ilova haqida', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '🔐 SecureCrypt Mobile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00FFAB)),
              ),
              SizedBox(height: 12),
              Text(
                'SecureCrypt Mobile — bu zamonaviy, xavfsiz va qulay mobil ilova bo‘lib, foydalanuvchilarga matn, fayl va multimedia maʼlumotlarini ishonchli tarzda shifrlash va yashirish imkonini beradi.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(height: 20),
              Text('🧩 Asosiy imkoniyatlar:', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 10),
              Text('• Matnni shifrlash/deshifrlash (AES, RSA, Vigenère, Caesar)', style: TextStyle(color: Colors.white70)),
              Text('• Har qanday faylni (PDF, DOCX, ZIP, MP3, MP4, JPG, PNG, RAR va h.k.) shifrlash/deshifrlash (AES)', style: TextStyle(color: Colors.white70)),
              Text('• Rasm ichiga maxfiy matnni yashirish va uni ajratib olish (Steganografiya, LSB)', style: TextStyle(color: Colors.white70)),
              Text('• QR kod orqali shifrlangan maʼlumotni ulashish', style: TextStyle(color: Colors.white70)),
              Text('• Biometrik autentifikatsiya (Face ID / Fingerprint)', style: TextStyle(color: Colors.white70)),
              Text('• Clipboard (nusxalash/joylashtirish) va fayl ulashish funksiyasi', style: TextStyle(color: Colors.white70)),
              Text('• Matnli interfeys, statistika, profil maʼlumotlarini boshqarish', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 24),
              Text('📁 Qo‘llab-quvvatlanadigan fayl formatlari:', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Text('• Matn: .txt, .json, .csv', style: TextStyle(color: Colors.white70)),
              Text('• Hujjatlar: .pdf, .docx, .pptx, .xls', style: TextStyle(color: Colors.white70)),
              Text('• Media: .jpg, .png, .mp3, .mp4, .wav, .avi', style: TextStyle(color: Colors.white70)),
              Text('• Arxivlar: .zip, .rar, .7z', style: TextStyle(color: Colors.white70)),
              Text('• Maxsus: .enc (ilovada yaratilgan shifrlangan fayl)', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 24),
              Text('🛠 Texnologiyalar:', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Text('• Dasturlash tili: Dart (Flutter SDK)', style: TextStyle(color: Colors.white70)),
              Text('• Shifrlash: pointycastle, basic_utils', style: TextStyle(color: Colors.white70)),
              Text('• Fayl tanlash: file_selector', style: TextStyle(color: Colors.white70)),
              Text('• Biometrika: local_auth', style: TextStyle(color: Colors.white70)),
              Text('• Ulashish: share_plus', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 24),
              Text('📱 Ilova versiyasi: 1.0.0', style: TextStyle(color: Colors.white54)),
              Text('👨‍💻 Dasturchi: Bobomurodov Jaloliddin', style: TextStyle(color: Colors.white54)),
              Text('📅 Sana: 2025', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}
