import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'MainScreen.dart';

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final _pinController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _verifyPin() async {
    final savedPin = await _storage.read(key: 'user_pin');

    if (savedPin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("pin_not_set".tr())),
      );
      return;
    }

    if (_pinController.text == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("pin_incorrect".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF101010), Color(0xFF1a1a1a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Color(0xFF00FFAB)),
              const SizedBox(height: 24),
              Text(
                "enter_pin".tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[850]?.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: _pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    letterSpacing: 12,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "pin_hint".tr(),
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open),
                  label: Text(
                    "login".tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _verifyPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFAB),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
