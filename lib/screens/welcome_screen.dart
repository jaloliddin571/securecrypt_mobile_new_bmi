import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _setLocaleAndContinue(BuildContext context, Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale.languageCode);
    await context.setLocale(locale);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select your language',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              const SizedBox(height: 30),
              _buildLangButton(context, '🇺🇿 O‘zbek', const Locale('uz')),
              _buildLangButton(context, '🇷🇺 Русский', const Locale('ru')),
              _buildLangButton(context, '🇬🇧 English', const Locale('en')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String label, Locale locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _setLocaleAndContinue(context, locale),
        child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
