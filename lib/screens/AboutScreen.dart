import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
        title: Text('about_app_title'.tr(), style: const TextStyle(color: Colors.white)), // ℹ️ Ilova haqida
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'app_name'.tr(), // 🔐 SecureCrypt Mobile
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00FFAB)),
              ),
              const SizedBox(height: 12),
              Text(
                'app_description'.tr(),
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Text('main_features_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)), // 🧩 Asosiy imkoniyatlar:
              const SizedBox(height: 10),
              Text('feature_1'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('feature_2'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('feature_3'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('feature_4'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('feature_5'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('feature_6'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('feature_7'.tr(), style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              Text('supported_formats_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)), // 📁 Qo‘llab-quvvatlanadigan fayl formatlari:
              const SizedBox(height: 8),
              Text('format_text'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('format_docs'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('format_media'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('format_archives'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('format_special'.tr(), style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              Text('technologies_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)), // 🛠 Texnologiyalar:
              const SizedBox(height: 8),
              Text('tech_1'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('tech_2'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('tech_3'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('tech_4'.tr(), style: const TextStyle(color: Colors.white70)),
              Text('tech_5'.tr(), style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              Text('app_version'.tr(), style: const TextStyle(color: Colors.white54)),
              Text('developer'.tr(), style: const TextStyle(color: Colors.white54)),
              Text('release_year'.tr(), style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}
